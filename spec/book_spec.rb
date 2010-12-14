# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::Book do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
  end

  it 'has title' do
    @book.title.should == '正義の叫'
  end

  it 'has total_page' do
    @book.total_page.should == 31
  end

  it 'has author' do
    @book.author.should == '正義熱血社'
  end

  it 'has spread' do
    @book.spread_at(1).should be_a_kind_of Kindai::Spread
  end


  it 'has base_uri' do
    @book.base_uri.should == "http://kindai.da.ndl.go.jp/scrpt/ndlimageviewer-rgc.aspx?pid=info%3Andljp%2Fpid%2F922693&jp=42016454&vol=10010&koma=1&vs=10000,10000,0,0,0,0,0,0"
  end

end
