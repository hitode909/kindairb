# -*- coding: utf-8 -*-
module Kindai
  class Publisher
    attr_accessor :book

    def self.new_from_book(book)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
      me = self.new
      me.book = book
      me
    end

    def method_missing(name, *args)
      Kindai::Util.logger.warn("#{name}, #{args} called")
    end

    def publish
      Kindai::Util.logger.info("published")
    end

  end
end
