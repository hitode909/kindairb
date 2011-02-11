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
    @downloader.retry_count.should == 30
    @downloader.retry_count = 50
    @downloader.retry_count.should == 50
  end

  it 'has base path' do
    @downloader.base_path = "/path/to/library"
    @downloader.book_path.should == "/path/to/library/正義熱血社 - 正義の叫"

    @downloader.base_path = "/path/to/library/"
    @downloader.book_path.should == "/path/to/library/正義熱血社 - 正義の叫"
  end

  it 'can download book' do
    base_path = File.join(ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || '/tmp', rand.to_s)
    Dir.mkdir(base_path)
    @downloader.base_path = base_path

    @downloader.has_file?.should be_false
    @downloader.download.should be_true
    @downloader.has_file?.should be_true
    @downloader.download.should be_false

    @downloader.delete.should be_true
    @downloader.has_file?.should be_false
    @downloader.delete.should be_false

    Dir.delete(base_path)
  end


end
