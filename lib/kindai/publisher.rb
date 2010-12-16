# -*- coding: utf-8 -*-
module Kindai
  class Publisher
    attr_accessor :root_path

    def self.new_from_path(root_path)
      me = self.new
      me.root_path = root_path
      me
    end

    def name(n)
      config(:name, n)
      self
    end

    def resize(width, height)
      config(:resize, {:width => width, :height => height})
      self
    end

    def trim(geometry = true)
      config(:trim, geometry)
      self
    end

    def zip
      config(:zip, true)
      self
    end

    def publish
      Kindai::Util.logger.info("publish")
      raise "no name" unless config(:name)

      create_directory

      trim! if trim?
      resize! if resize?
      zip! if zip?
    end

    # ------------------------------------
    protected

    def config(k, v = nil)
      return @config[k] unless v
      @config ||= {}
      @config[k] = v
      @config
    end

    def trim?
      config(:trim)
    end

    def resize?
      config(:resize)
    end

    def zip?
      config(:zip)
    end

    def trim!
      Kindai::Util.logger.info 'trim'
      return if original_files.length == files(trim_path).length
      info = config(:trim).kind_of?(Hash) ? config(:trim) : Kindai::Util.trim_info_by_files(original_files)
      original_files.each{|file|
        dst = File.join(trim_path, File.basename(file))
        Kindai::Util.trim_file_to(file, dst, info)
        GC.start
      }
    end

    def resize!
      Kindai::Util.logger.info 'resize'
      p @config
      p config(:resize)
      original_files.each{|file|
        dst = File.join(output_path, File.basename(file))
        Kindai::Util.resize_file_to(file, dst, config(:resize))
        GC.start
      }
    end

    def zip!
      Kindai::Util.logger.info 'zip'
      Kindai::Util.generate_zip(output_path)
    end

    def create_directory
      path = File.join root_path, config(:name)
      Dir.mkdir(path) unless File.directory?(path)
      path = File.join root_path, 'trim'
      Dir.mkdir(path) unless File.directory?(path)
    end

    def source_path
      trim? ? trim_path : original_path
    end

    def trim_path
      File.join(root_path, 'trim')
    end

    def original_path
      File.join(root_path, 'original')
    end

    def output_path
      File.join(root_path, config(:name))
    end

    def original_files
      files(original_path)
    end

    def files(path)
      Dir.glob(File.join(path, '*jpg'))
    end

  end
end
