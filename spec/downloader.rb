$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'kindai'

describe Kindai::Downloader do
  it 'can initialize from book id' do
    [nil, 1, "hello"].each { |a|
      lambda{ Kindai::Downloader.new_from_book a }.should raise_error(TypeError)
    }
  end
end
