# -*- coding: utf-8 -*-
module Kindai
  class Publisher
    attr_accessor :root_path
    attr_accessor :book

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
      config(:trim, geometry) unless config(:trim)
      self
    end

    def zip
      config(:zip, true)
      self
    end

    def divide
      config(:divide, true)
      self
    end

    def empty(glob)
      FileUtils.rm_r(Dir.glob(File.join(self.root_path, glob)))
    end

    def publish
      Kindai::Util.logger.info("publish #{root_path}, #{config(:name)}")
      raise "no name" unless config(:name)
      self.ensure_book
      if seems_finished?
        Kindai::Util.logger.info("already published")
        return
      end
      create_directory

      path = original_path

      path = trim!(path) if trim?
      path = divide!(path) if divide?
      path = resize!(path) if resize?
      path = zip!(path) if zip?
    end

    def publish_auto
      self.ensure_book
      self.clone.trim.resize(1280, 960).trim.zip.name('iphone').publish
      self.clone.trim.resize(600, 800).divide.zip.name('kindle').publish
    end

    def publish_default
      self.ensure_book
      self.clone.trim.name('default').publish
    end

    def publish_for_iphone
      self.ensure_book
      self.clone.trim.resize(1280, 960).trim.zip.name('iphone').publish
    end

    def publish_for_kindle
      self.ensure_book
      self.clone.trim.resize(600, 800).divide.zip.name('kindle').publish
    end

    def ensure_book
      @book ||= Kindai::Book.new_from_local_directory(root_path)
      true
    end

    # ------------------------------------
    protected

    def config(k, v = nil)
      @config ||= {}
      return @config[k] unless v
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

    def divide?
      config(:divide)
    end

    # ---------- aciton --------------

    def trim!(source_path)
      return trim_path if files(source_path).length == files(trim_path).length
      info = config(:trim).kind_of?(Hash) ? config(:trim) : Kindai::Util.trim_info_auto(book, original_files)
      Kindai::Util.logger.info "trim position: #{info}"
      files(source_path).each{|file|
        dst = File.join(trim_path, File.basename(file))
        Kindai::Util.trim_file_to(file, dst, info)
        GC.start
      }
      return trim_path
    end

    def resize!(source_path)
      files(source_path).each{|file|
        dst = File.join(output_path, File.basename(file))
        Kindai::Util.resize_file_to(file, dst, config(:resize))
        GC.start
      }
      return output_path
    end

    def divide!(source_path)
      files(source_path).each{|file|
        Kindai::Util.divide_43(file, output_path)
        GC.start
      }
      return output_path
    end

    def zip!(source_path)
      Kindai::Util.generate_zip(source_path)
      FileUtils.rm_r(self.output_path)
      return source_path
    end

    # ---------util------------

    def create_directory
      Dir.mkdir(trim_path) unless File.directory?(trim_path)
      Dir.mkdir(output_path) unless File.directory?(output_path)
    end

    def trim_path
      File.join(root_path, 'trim')
    end

    def original_path
      File.join(root_path, 'original')
    end

    def output_path
      File.join(root_path, File.basename(root_path) + '_' + config(:name))
    end

    def original_files
      files(original_path)
    end

    def files(path)
      Dir.glob(File.join(path, '*jpg'))
    end

    def seems_finished?
      zip? ? File.exists?(output_path + '.zip') : File.directory?(output_path)
    end

  end
end
