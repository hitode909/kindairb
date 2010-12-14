# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::BookDownloader do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
    @downloader   = Kindai::BookDownloader.new_from_book(@book)
  end

  it 'has book' do
    @downloader.book.should == @book
  end

  it 'has retry_count' do
    @downloader.retry_count.should == 0
    @downloader.retry_count = 3
    @downloader.retry_count.should == 3
  end

  it 'has base path' do
    @downloader.base_path = "/path/to/library"
    @downloader.book_path.should == "/path/to/library/正義熱血社 - 正義の叫"

    @downloader.base_path = "/path/to/library/"
    @downloader.book_path.should == "/path/to/library/正義熱血社 - 正義の叫"
  end

end
