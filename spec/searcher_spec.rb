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

end
