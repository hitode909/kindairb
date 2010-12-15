# -*- coding: utf-8 -*-
require 'open3'
require 'tempfile'
require 'digest/sha1'
require 'RMagick'

module Kindai::Util
  def self.logger
    @logger ||= Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger
  end

  def self.debug_mode
    self.logger.level = Logger::DEBUG
    Kindai::Util.logger.info "debug mode enabled"
  end

  def self.exec(command)
    logger.debug "exec #{command}"
    `#{command}`
  end

  def self.download(url, file)
    open(file, 'w') {|local|
      got = open(url) {|remote|
        local.write(remote.read)
      }
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
    params.each_pair.map{ |k, v| [URI.escape(k.to_s), URI.escape(v.to_s)].join('=')}.join('&')
  end

  def self.convert_required
    raise "convert is required" if `which convert`.empty?
  end

  def self.check_file(path)
    return true if `which convert`.empty?

    stdin, stdout, stderr = Open3.popen3('convert', path, Tempfile.new('dummy').path)
    r = stderr.read
    r.empty?
  end

  def self.divide(path)
    raise "#{path} not exist" unless File.exists? path
    Kindai::Util.logger.info "dividing #{path}"

    Kindai::Util.logger.debug "convert -fuzz 25% -trim '#{path}' '#{path}'"
    system "convert -fuzz 25% -trim '#{path}' '#{path}'"

    info = `identify '#{path}'`
    image_width, image_height = *info.scan(/(\d+)x(\d+)/).first.map(&:to_i)
    Kindai::Util.logger.debug [image_width, image_height]

    Kindai::Util.logger.debug "convert -crop  '#{path}' '#{path}'"
    system "convert -crop #{image_height*0.75}x#{image_height}+#{image_width - image_height*0.75}+0 '#{path}' '#{append_suffix(path, '0')}'"
    system "convert -crop #{image_height*0.75}x#{image_height}+0+0 '#{path}' '#{append_suffix(path, '1')}'"

    File.delete path

    [append_suffix(path, '0'), append_suffix(path, '1')]
  end

  def self._divide(path)
    raise "#{path} not exist" unless File.exists? path

    Kindai::Util.logger.info "dividing #{path}"

    Kindai::Util.logger.debug "convert -fuzz 25% -trim '#{path}' '#{path}'"
    system "convert -fuzz 25% -trim '#{path}' '#{path}'"

    Kindai::Util.logger.debug "convert -crop 50%x100% '#{path}' '#{path}'"
    system "convert -crop 50%x100% '#{path}' '#{path}'"

    File.rename append_suffix(path, '0'), append_suffix(path, 'tmp')
    File.rename append_suffix(path, '1'), append_suffix(path, '0')
    File.rename append_suffix(path, 'tmp'), append_suffix(path, '1')
    File.delete path
    [append_suffix(path, '0'), append_suffix(path, '1')]
  end

  def self.append_suffix(path, suffix)
    path.gsub(/\.(\w+)$/, "-#{suffix}.\\1")
  end

  def self.generate_pdf(directory, title = nil)
    raise "#{directory} is not directory." unless File.directory? directory

    Kindai::Util.logger.info "generating pdf"

    app_path = File.expand_path(File.dirname(__FILE__) + '/../../app/topdf.app')
    directory = File.expand_path(directory)
    Kindai::Util.logger.debug "open -a #{app_path} -W '#{directory}'"
    system "open -a #{app_path} -W '#{directory}'"

    if title
      from = Dir.pwd
      Dir.chdir(directory)
      File.rename(Dir.glob('*pdf').last, "../#{title}.pdf")
      Dir.chdir(from)
    end

    Kindai::Util.logger.info "generating pdf done"
  end

  def self.generate_zip(directory)
    directory = File.expand_path(directory)
    raise "#{directory} is not directory." unless File.directory? directory

    from = Dir.pwd
    Dir.chdir(directory)

    Kindai::Util.logger.info "generating zip"
    Kindai::Util.logger.debug "zip -q -r '#{Time.now.to_i}.zip' *jpg"
    system "zip -q -r '#{Time.now.to_i}.zip' *jpg"
    title = File.basename(directory)
    File.rename(Dir.glob('*zip').last, "../#{title}.zip")

    Dir.chdir(from)
  end

  def self.fetch_uri(uri, rich = false)
    uri = URI.parse(uri) unless uri.kind_of? URI

    return uri.read unless rich

    total = nil
    from = Time.now
    uri.read(
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
  end

  # XXX: GC
  def self.trim_info(img_path, erase_center_line = true)
    debug = true
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
      Kindai::Util.logger.info "x: #{info[:x]} -> #{new_info[:x]}"
      Kindai::Util.logger.info "width: #{info[:width]} -> #{new_info[:width]}"
      info[:x] = new_info[:x]
      info[:width] = new_info[:width]
    else
      warn 'ok'
    end

    img = nil
    thumb = nil

    return info
  end

  def self.trim_file_to(src_path, dst_path, info = nil)
    info = trim_info(src_path) unless info

    img = Magick::ImageList.new(src_path)
    img.crop! info[:x], info[:y], info[:width], info[:height]
    img.write dst_path

    img = nil
  end

end
