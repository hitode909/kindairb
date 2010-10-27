1# -*- coding: utf-8 -*-
module Kindai::Interface
  def self.download_url(url, config = { })
    book = Kindai::Book.new_from_permalink(url)
    downloader = Kindai::Downloader.new_from_book(book)
    downloader.output_directory = config[:output_directory] if config[:output_directory]
    downloader.use_trim if config[:trim]
    Kindai::Util.logger.info "download #{book.title}(#{book.page} pages) to #{downloader.full_directory_path}"
    downloader.download
  end

  def self.download_keyword(keyword, config = { })
    Kindai::Searcher.search(keyword) { |url, at, total|
      Kindai::Util.logger.info "#{at} / #{total}"
      download_url url
    }
  end
end
