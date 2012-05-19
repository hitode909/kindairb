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

end

describe Kindai::Book, 'with series' do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.da.ndl.go.jp/info:ndljp/pid/890078')
  end

  it 'has title' do
    @book.title.should == '講談日露戦争記3'
  end
end

describe Kindai::Book, 'from without any uri' do
  it 'will die' do
    empty_book = Kindai::Book.new
    lambda { empty_book.permalink_uri }.should raise_error Exception
  end
end
