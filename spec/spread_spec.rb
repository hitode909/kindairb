# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::Spread do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
    @spread = @book.spread_at(5)
  end

  it 'has spread number' do
    @spread.spread_number.should == 5
  end

  it 'has book' do
    @spread.book.should == @book
  end

  it 'has spread url' do
    @spread.url.should == @book
  end

end
