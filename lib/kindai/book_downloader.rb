# -*- coding: utf-8 -*-
module Kindai
  class BookDownloader
    attr_accessor :book
    attr_accessor :retry_count
    attr_accessor :base_path

    def self.new_from_book(book)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
      me = self.new
      me.book = book
      me.retry_count = 30
      me.base_path = Dir.pwd
      me
    end

    def download
      create_directory
      write_metadata
      return false if self.has_file?
      download_spreads
      return true
    end

    def safe_filename filename
      filename.gsub(File::SEPARATOR, '_')
    end

    def book_path
      path = File.join(self.base_path, safe_filename([@book.author, @book.title].compact.join(' - ')))
      File.expand_path path
    end

    def create_directory
      Dir.mkdir(book_path) unless File.directory?(book_path)
    end

    def delete
      success = true
      FileUtils.rm_r(self.book_path) rescue success = false
      return success
    end

    def write_metadata
      open(metadata_path, 'w') {|f|
        f.puts book.permalink_uri
      }  unless File.exists?(metadata_path)
    end

    def metadata_path
      File.join(book_path, 'metadata')
    end

    def has_file?
      File.directory?(self.book_path) && self.spread_downloaders.all?(&:has_file?)
    end

    # --------------------------------------------------------------------
    protected

    def spread_downloaders
      self.book.spreads.map{|spread|
        dl = Kindai::SpreadDownloader.new_from_spread(spread)
        dl.retry_count = self.retry_count
        dl.book_path = self.book_path
        dl
      }
    end

    def download_spreads
      is_first = true
      self.spread_downloaders.each{ |dl|
        next if dl.has_file?
        sleep 20 unless is_first
        is_first = false
        dl.download
      }

      return true
    end
  end
end
