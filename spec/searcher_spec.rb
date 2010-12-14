# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::Searcher do
  before do
    Kindai::Util.logger.level = Logger::DEBUG
    @searcher = Kindai::Searcher.search('我輩は')
  end

  it 'is Searcher' do
    @searcher.should be_a_instance_of Kindai::Searcher
  end

  it 'has length' do
    @searcher.length.should satisfy{|length| length > 10}
  end

  it 'has iterator' do
    count = 0
    @searcher.each{|book|
      count += 1
      book.should be_a_instance_of Kindai::Book
    }
    count.should == @searcher.length
  end


  # it 'has total page' do
  #   @book.total_page.should == 31
  # end

  # it 'has total sprea' do
  #   @book.total_spread.should == 20
  # end

  # it 'has author' do
  #   @book.author.should == '正義熱血社'
  # end

  # it 'has spreads' do
  #   @book.spreads.should have_exactly(@book.total_spread).spreads
  # end

  # it 'has base_uri' do
  #   @book.base_uri.should == "http://kindai.da.ndl.go.jp/scrpt/ndlimageviewer-rgc.aspx?pid=info%3Andljp%2Fpid%2F922693&jp=42016454&vol=10010&koma=1&vs=10000,10000,0,0,0,0,0,0"
  # end

end
