# -*- coding: utf-8 -*-
module Kindai::Interface
  def self.download_url(url, config = { })
    book = Kindai::Book.new_from_permalink(url)
    download_book(book, config)
  end

  def self.download_book(book, config = { })
    downloader = Kindai::BookDownloader.new_from_book(book)
    downloader.base_path = config[:base_path] if config[:base_path]
    downloader.retry_count = config[:retry_count] if config[:retry_count]
    Kindai::Util.logger.info "download #{book.title}(#{book.total_spread} spreads) to #{downloader.book_path}"
    downloader.download

    publisher = Kindai::Publisher.new_from_path downloader.book_path
    publisher.publish_auto
  end

  def self.download_keyword(keyword, config = { })
    searcher = Kindai::Searcher.search(keyword)
    searcher.each_with_index { |book, index|
      begin
        Kindai::Util.logger.info "book #{index+1} / #{searcher.length}"
        download_book book, config
      rescue => error
        p error
      end
    }
  end
end
