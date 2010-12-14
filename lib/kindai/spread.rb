# -*- coding: utf-8 -*-
module Kindai
  class Spread
    attr_accessor :book
    attr_accessor :spread_number

    def self.new_from_book_and_spread_number(book, spread_number)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
      me = self.new
      me.book = book
      me.spread_number = spread_number
      me
    end

    def image_url
    end

    def exist?
    end

    def has_local_file?
    end

    def local_file_path
    end

  end
end
