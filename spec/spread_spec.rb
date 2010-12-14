# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kindai::Spread do
  before do
    @book = Kindai::Book.new_from_permalink('http://kindai.ndl.go.jp/info:ndljp/pid/922693')
    @spread = @book.spreads[4]
  end

  it 'has spread number' do
    @spread.spread_number.should == 5
  end

  it 'has book' do
    @spread.book.should == @book
  end

  it 'has uri' do
    @spread.uri.should == "http://kindai.da.ndl.go.jp/scrpt/ndlimageviewer-rgc.aspx?pid=info%3Andljp%2Fpid%2F922693&jp=42016454&vol=10010&koma=5&vs=10000,10000,0,0,0,0,0,0"
  end

  it 'has image_uri' do
    @spread.image_uri.should == "http://kindai.da.ndl.go.jp/JPEG/ESY13.jpg"
  end

end
