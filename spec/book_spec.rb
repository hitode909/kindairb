# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
    @book.author.should == "正義熱血社出版部"
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
