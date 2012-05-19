# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::Book, 'from search result uri' do
  before do
    @book = Kindai::Book.new_from_search_result_uri('http://iss.ndl.go.jp/books/R000000008-I000162417-00')
  end

  it 'is a book' do
    @book.should be_kind_of Kindai::Book
  end

  it 'has permalink' do
    @book.permalink_uri.should == 'http://kindai.da.ndl.go.jp/info:ndljp/pid/922693'
  end

  it 'has key' do
    @book.key.should == "922693"
  end
end

describe Kindai::Book do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
  end

  it 'has key' do
    @book.key.should == "922693"
  end

  it 'has title' do
    @book.title.should == '正義の叫'
  end

  it 'has total spread' do
    @book.total_spread.should == 20
  end

  it 'has author' do
    @book.author.should == '正義熱血社'
  end

  it 'has spreads' do
    @book.spreads.should have_exactly(@book.total_spread).spreads
  end

  # it 'has base_uri' do
  #   @book.base_uri.should == "http://kindai.da.ndl.go.jp/scrpt/ndlimageviewer-rgc.aspx?pid=info%3Andljp%2Fpid%2F922693&jp=42016454&vol=10010&koma=1&vs=10000,10000,0,0,0,0,0,0"
  # end

end

describe Kindai::Book, 'with series' do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.da.ndl.go.jp/info:ndljp/pid/890078')
  end

  it 'has title' do
    @book.title.should == '講談日露戦争記3'
  end
end

describe Kindai::Book, 'with trimming' do
  before do

    @trimming = {:x => 342, :y => 190, :w => 2829, :h => 2485, :resize_w => 900, :resize_h => 900}
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693', @trimming)
    @book_normal = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
  end

  it 'has trimming' do
    @book.trimming.should be_kind_of Hash
    @book.trimming.should == @trimming
  end

  it 'has base uri including trimming info' do
    @book.base_uri.should match(/2485/)
  end

  it 'has different image uri' do
    @book.spreads.first.uri.should_not == @book_normal.spreads.first.uri
  end

end




