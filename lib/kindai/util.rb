# -*- coding: utf-8 -*-
require 'open3'
require 'tempfile'
require 'digest/sha1'

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
    uri.read(
      :content_length_proc => proc{|_total|
        total = _total
      },
      :progress_proc => proc{|now|
        if rand > 0.5
          print "%3d%% #{now}/#{total}\r" % (now/total.to_f*100)
          $stdout.flush
        end
      })
  end

end
