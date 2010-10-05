$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'kindai'

describe Kindai::Book do
  it 'can initialize from book id' do
    book = Kindai::Book.new_from_book_id(881214)
    book.permalink.should == "http://kindai.da.ndl.go.jp/info:ndljp/pid/881214/1"
  end

  it 'can initialize from detail url' do
    book = Kindai::Book.new_from_detail_url("spec/BIBibDetail881214")
    book.permalink.should == "http://kindai.da.ndl.go.jp/info:ndljp/pid/881214/1"
  end
end
