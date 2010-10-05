# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'kindai'

describe Kindai::Book do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
  end

  it 'has title' do
    @book.title.should == '正義の叫'
  end

  it 'has page' do
    @book.page.should == 31
  end

  it 'has author' do
    @book.author.should == '正義熱血社'
  end

end
