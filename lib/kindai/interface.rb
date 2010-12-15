# -*- coding: utf-8 -*-
module Kindai::Interface
  def self.download_url(url, config = { })
    book = Kindai::Book.new_from_permalink(url)
    download_book(book, config)
  end

  def self.download_book(book, config = { })
    downloader = Kindai::BookDownloader.new_from_book(book)
    downloader.output_directory = config[:output_directory] if config[:output_directory]
    downloader.retry_count = config[:retry_count] if config[:retry_count]
    Kindai::Util.logger.info "download #{book.title}(#{book.total_page} pages) to #{downloader.book_path}"
    downloader.download
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
