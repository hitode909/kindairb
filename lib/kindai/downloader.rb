module Kindai
  class Downloader
    def self.download_book(book)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
    end
  end
end
