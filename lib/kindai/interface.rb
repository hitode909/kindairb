# -*- coding: utf-8 -*-
module Kindai::Interface
  def self.download_url(url, config = { })
    book = Kindai::Book.new_from_permalink(url)
    downloader = Kindai::BookDownloader.new_from_book(book)
    downloader.output_directory = config[:output_directory] if config[:output_directory]
    downloader.retry_count = config[:retry_count] if config[:retry_count]
    Kindai::Util.logger.info "download #{book.title}(#{book.total_page} pages) to #{downloader.book_path}"
    downloader.download

    # publisher = Kindai::Publisher.new_from_book(book)
    # publisher.use_divide if config[:use_divide]
    # publisher.use_pdf if config[:use_pdf]
    # publisher.use_zip if config[:use_zip]
    # publisher.test_mode if config[:test_mode]
    # publisher.resize_option = config[:resize_option] if config[:resize_option]
    # publisher.set_trimming(
    #   :x => config[:trimming_x] || 0,
    #   :y => config[:trimming_y] || 0,
    #   :w => config[:trimming_w] || 5000,
    #   :h => config[:trimming_h] || 5000,
    #   ) if config[:trimming_x] || config[:trimming_y] || config[:trimming_w] || config[:trimming_h]
    # publisher.publish

    # publisher.publish_trimmed_pdf
    # publisher.publish_kindle
  end

  def self.download_keyword(keyword, config = { })
    Kindai::Searcher.search(keyword) { |url, at, total|
      Kindai::Util.logger.info "#{at} / #{total}"
      download_url url, config
    }
  end
end
