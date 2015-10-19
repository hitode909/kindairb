# -*- coding: utf-8 -*-
require 'open3'
require 'tempfile'
require 'digest/sha1'
require 'rmagick'
require 'zipruby'
require 'net/http'

module Kindai::Util
  def self.logger
    return @logger if @logger
    @logger ||= Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger
  end

  def self.debug_mode!
    self.logger.level = Logger::DEBUG
    Kindai::Util.logger.info "debug mode enabled"
  end

  def self.download(uri, file)
    total = nil
    uri = URI.parse(uri) unless uri.kind_of? URI

    got = fetch_uri(uri)
    open(file, 'w') {|local|
      local.write(got)
    }
  rescue Exception, TimeoutError => error
    if File.exists?(file)
      logger.debug "delete cache"
      File.delete(file)
    end
    raise error
  end

  def self.rich_download(uri, file)
    total = nil
    uri = URI.parse(uri) unless uri.kind_of? URI

    got = fetch_uri(uri, true)
    open(file, 'w') {|local|
      local.write(got)
    }
  rescue Exception, TimeoutError => error
    if File.exists?(file)
      logger.debug "delete cache"
      File.delete(file)
    end
    raise error
  end

  # input:  {:a => 'a', :b => 'bbb'}
  # output: 'a=a&b=bbb
  def self.expand_params(params)
    URI.encode_www_form(params)
  end

  def self.append_suffix(path, suffix)
    path.gsub(/\.(\w+)$/, "-#{suffix}.\\1")
  end

  def self.execute_and_log(command)
    logger.debug command
    system command or raise "#{commands} failed"
  end

  def self.generate_zip(directory)
    Kindai::Util.logger.info "zip #{directory}"
    directory = File.expand_path(directory)
    raise "#{directory} is not directory." unless File.directory? directory

    filename = File.expand_path(File.join(directory, '..', "#{File.basename(directory)}.zip"))
    files = Dir.glob(File.join(directory, '*jpg'))
    begin
      Zip::Archive.open(filename, Zip::CREATE) {|arc|
        files.each{|f| arc.add_file(f) }
      }
    rescue => error
      File.delete(filename) if File.exists?(filename)
      logger.warn "#{error.class}: #{error.message}"
      logger.warn "zipruby died. trying zip command"
      generate_zip_system_command(directory)
    end
  end

  def self.generate_zip_system_command(directory)
    Kindai::Util.logger.info "zip(system) #{directory}"
    from = Dir.pwd
    Dir.chdir(directory)
    execute_and_log "zip -q -r '../#{File.basename(directory)}.zip' *jpg"
    Dir.chdir(from)
  end

  def self.fetch_uri(uri, rich = false)
    uri = URI.parse(uri) unless uri.kind_of? URI
    self.logger.debug "fetch_uri #{uri}"

    return uri.read unless rich

    total = nil
    from = Time.now
    got = uri.read(
      :content_length_proc => proc{|_total|
        total = _total
      },
      :progress_proc => proc{|now|
        if Time.now - from > 0.2
          from = Time.now
          print "%3d%% #{now}/#{total}\r" % (now/total.to_f*100)
          $stdout.flush
        end
      })
    raise "received size unmatch(#{got.bytesize}, #{total})" if got.bytesize != total
    return got
  end

  def self.get_redirected_uri(uri)
    uri = URI.parse(uri) unless uri.kind_of? URI
    self.logger.debug "get_redirected_uri #{uri}"

    response = nil
    proxy_uri = URI.parse(ENV["http_proxy"] || ENV["HTTP_PROXY"] || "")
    proxy_user, proxy_pass = proxy.userinfo.split(/:/) if proxy_uri.userinfo
    Net::HTTP.Proxy(proxy_uri.host, proxy_uri.port,
                    proxy_user, proxy_pass).start(uri.host, uri.port) {|http|
      response = http.head(uri.request_uri)
    }
    response['Location']
  end

  def self.trim_info_auto(book, files)
    info = nil
    item = Kindai::Util::Database.item_for_book(book)
    if item
      self.logger.info "found trimming info"
      return {
        :x      => item[:x],
        :y      => item[:y],
        :width  => item[:width],
        :height => item[:height],
      }
    end

    info = self.trim_info_by_files(files)
    self.logger.info "save trimming info"
    Kindai::Util::Database.save_item(book, info)
    return info
  rescue => error
    self.logger.error "#{error.class}: #{error.message}"
    info || self.trim_info_by_files(files)
  end

  def self.trim_info_by_files(files)
    Kindai::Util.logger.info "get trimming info"
    positions = {:x => [], :y => [], :width => [], :height => []}
    files.each{|file|
      pos = trim_info(file)

      [:x, :y, :width, :height].each{|key|
        positions[key] << pos[key]
      }

      GC.start
    }

    good_pos = {}
    [:x, :y, :width, :height].each{|key|
      good_pos[key] = average(positions[key])
    }
    good_pos
  end

  # XXX: GC
  def self.trim_info(img_path, erase_center_line = true)
    debug = false
    img = Magick::ImageList.new(img_path)

    thumb = img.resize_to_fit(400, 400)

    thumb.write('a1.jpg') if debug
    # thumb = thumb.normalize
    thumb = thumb.level(Magick::QuantumRange*0.4, Magick::QuantumRange*0.7)
    thumb.write('a2.jpg') if debug

    d = Magick::Draw.new
    d.fill = 'white'
    cut_x = 0.07
    cut_y = 0.04
    d.rectangle(thumb.columns * 0.4, 0, thumb.columns * 0.6, thumb.rows) if erase_center_line # center line
    d.rectangle(0, 0, thumb.columns * cut_x, thumb.rows) # h
    d.rectangle(0, thumb.rows * (1 - cut_y), thumb.columns, thumb.rows)    # j
    d.rectangle(0, 0, thumb.columns, thumb.rows * cut_y)             # k
    d.rectangle(thumb.columns * (1 - cut_x), 0, thumb.columns, thumb.rows) # l
    d.draw(thumb)
    thumb.write('a.jpg') if debug

    # thumb = thumb.threshold(Magick::QuantumRange*0.8)
    # thumb.write('b.jpg') if debug

    thumb.fuzz = 50
    thumb.trim!
    thumb.write('c.jpg') if debug

    scale = thumb.base_columns / thumb.page.width.to_f

    info = {
      :x => thumb.page.x * scale,
      :y => thumb.page.y * scale,
      :width => thumb.columns * scale,
      :height => thumb.rows * scale
    }

    # erased by cente line?
    if (thumb.page.x / thumb.page.width.to_f - 0.6).abs < 0.05 && erase_center_line
      Kindai::Util.logger.info "retry trim(erased by center line?)"
      new_info = trim_info(img_path, false)
      Kindai::Util.logger.debug "x: #{info[:x]} -> #{new_info[:x]}"
      Kindai::Util.logger.debug "width: #{info[:width]} -> #{new_info[:width]}"
      info[:x] = new_info[:x]
      info[:width] = new_info[:width]
    end

    img = nil
    thumb = nil

    return info
  end

  def self.trim_file_to(src_path, dst_path, info = nil)
    info = trim_info(src_path) unless info
    Kindai::Util.logger.info "trim #{src_path}"

    img = Magick::ImageList.new(src_path)
    img.crop! info[:x], info[:y], info[:width], info[:height]
    img.write dst_path

    img = nil
  end


  def self.resize_file_to(src_path, dst_path, info)
    Kindai::Util.logger.info "resize #{src_path}"
    img = Magick::ImageList.new(src_path)
    img.resize_to_fit(info[:width], info[:height]).write dst_path

    img = nil
  end

  def self.average(array)
    array.inject{|a, b| a + b} / array.length.to_f
  end

  def self.divide_43(src_path, output_directory)
    raise "#{src_path} not exist" unless File.exists? src_path
    Kindai::Util.logger.info "divide #{src_path}"

    output_base = File.join(output_directory, File.basename(src_path))

    img = Magick::ImageList.new(src_path)

    right = img.crop(img.columns - img.rows * 0.75, 0, img.columns * 0.75, img.rows)
    right.write(append_suffix(output_base, '0'))
    right = nil

    left = img.crop(0, 0, img.rows * 0.75, img.rows)
    left.write(append_suffix(output_base, '1'))
    left = nil

    File.delete(src_path) if File.basename(src_path) == output_directory
  end


end
