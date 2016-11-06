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
      "#{book.permalink_uri}/#{spread_number.to_s}"
    end

    def image_uri
      params = {
        :itemId => "info:ndljp/pid/#{book.key}",
        :contentNo => spread_number,
        :outputScale => 1,
      }
      "http://dl.ndl.go.jp/view/jpegOutput?" + Kindai::Util.expand_params(params)
    end

    # protected
    # XXX: book use this
    def page
      @page ||= Nokogiri Kindai::Util.fetch_uri self.uri
    end

  end
end
