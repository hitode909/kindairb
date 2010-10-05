# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'kindai'

describe Kindai::Book do
  before do
    @shibukawa = Kindai::Book.new_from_detail_url("spec/file/BIBibDetail881214")
    @shibukawa.instance_variable_set(:@permalink, "spec/file/index881214")
  end

  it 'can initialize from book id' do
    book = Kindai::Book.new_from_book_id(881214)
    book.permalink.should == "http://kindai.da.ndl.go.jp/info:ndljp/pid/881214/1"
  end

  it 'can initialize from detail url' do
    book = Kindai::Book.new_from_detail_url("spec/file/BIBibDetail881214")
    book.permalink.should == "http://kindai.da.ndl.go.jp/info:ndljp/pid/881214/1"
  end

  it 'has title' do
    @shibukawa.title.should == '渋川流名誉柔術'
  end

  it 'has page' do
    @shibukawa.page.should == 197
  end

  it 'has author' do
    @shibukawa.author.should == '岡田，霞船'
  end

end
