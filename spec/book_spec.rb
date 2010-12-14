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

end
