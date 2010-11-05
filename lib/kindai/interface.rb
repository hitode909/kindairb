# -*- coding: utf-8 -*-
module Kindai::Interface
  def self.download_url(url, config = { })
    book = Kindai::Book.new_from_permalink(url)
    downloader = Kindai::Downloader.new_from_book(book)
    downloader.output_directory = config[:output_directory] if config[:output_directory]
    downloader.use_divide if config[:use_divide]
    downloader.use_pdf if config[:use_pdf]
    downloader.use_zip if config[:use_zip]
    downloader.test_mode if config[:test_mode]
    downloader.retry_count = config[:retry_count] if config[:retry_count]
    downloader.resize_option = config[:resize_option] if config[:resize_option]
    book.set_trimming(
      :x => config[:trimming_x] || 0,
      :y => config[:trimming_y] || 0,
      :w => config[:trimming_w] || 5000,
      :h => config[:trimming_h] || 5000,
      ) if config[:trimming_x] || config[:trimming_y] || config[:trimming_w] || config[:trimming_h]
    downloader
    Kindai::Util.logger.info "download #{book.title}(#{book.page} pages) to #{downloader.full_directory_path}"
    downloader.download
  end

  def self.download_keyword(keyword, config = { })
    Kindai::Searcher.search(keyword) { |url, at, total|
      Kindai::Util.logger.info "#{at} / #{total}"
      download_url url, config
    }
  end
end
