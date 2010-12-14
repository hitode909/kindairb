# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::SpreadDownloader do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
    @spread = @book.spreads[10]
    @downloader   = Kindai::SpreadDownloader.new_from_spread(@spread)
  end

  it 'has spread' do
    @downloader.spread.should == @spread
  end

  it 'has retry_count' do
    @downloader.retry_count.should == 0
    @downloader.retry_count = 3
    @downloader.retry_count.should == 3
  end

  it 'has spread path' do
    @downloader.book_path = "/path/to/book"
    @downloader.spread_path.should == "/path/to/book/011.jpg"

    @downloader.book_path = "/path/to/book/"
    @downloader.spread_path.should == "/path/to/book/011.jpg"
  end

  # it 'can download spread' do
  #   tempdir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || '/tmp'
  #   @downloader.download_to_path(tempdir)
  # end


end
