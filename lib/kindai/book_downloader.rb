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
      me.retry_count = 0
      me.base_path = Dir.pwd
      me
    end

    def download
      return false if self.has_file?
      create_directory
      download_spreads
      return true
    end

    def book_path
      path = File.join(self.base_path, [@book.author, @book.title].compact.join(' - '))
      File.expand_path path
    end

    def delete
      success = true
      File.delete(*self.spread_downloaders.map(&:spread_path)) rescue success = false
      Dir.delete(self.book_path) rescue success = false
      return success
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

    def create_directory
      Dir.mkdir(book_path) unless File.directory?(book_path)
    end

    def download_spreads
      self.spread_downloaders.each{|dl|
        dl.download
      }
      return true
    end
  end
end
