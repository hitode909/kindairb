# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::BookDownloader, 'with book which contains slash in title' do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/1057420')
    @downloader   = Kindai::BookDownloader.new_from_book(@book)
  end

  describe 'safe_filename' do
    it 'convert path separator to _' do
      @downloader.safe_filename('a/b').should == 'a_b'
      @downloader.safe_filename('a/b/c/d').should == 'a_b_c_d'
    end
  end

  it 'has base path' do
    @downloader.base_path = "/path/to/library"
    @downloader.book_path.should == "/path/to/library/BMW航空発動機会社 [著]三菱商事株式会社機械部 訳編 - BMW132Dc_1型発動機部品表"
  end
end



