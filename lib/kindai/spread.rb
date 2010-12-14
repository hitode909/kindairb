# -*- coding: utf-8 -*-
module Kindai
  class Spread
    attr_accessor :book
    attr_accessor :spread_number

    def self.new_from_book_and_spread_number(book, spread_number)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
      me = new
      me.book = book
      me.spread_number = spread_number
      me
    end

    def uri
      book.base_uri.gsub(/koma=(\d+)/) { "koma=#{spread_number}" }
    end

    def image_uri
      image = page.at("img#imMain")
      raise "not exists" unless image
      image['src']
    end


    def has_local_file?
    end

    def local_file_path
    end

    # protected
    # XXX: book use this
    def page
      @page ||= Nokogiri Kindai::Util.fetch_uri self.uri
    end

  end
end
