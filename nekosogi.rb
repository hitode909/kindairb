#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift('lib')
require 'kindai'
require 'optparse'
$config = { }
parser = OptionParser.new("example: ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693") {|opt|
  opt.on('-o OUTPUT_DIRECTORY', '--output', 'specify output directory') {|v| $config[:output] = v}
  opt.parse!(ARGV)
}
def download(url)
  book = Kindai::Book.new_from_permalink(url)

  downloader = Kindai::Downloader.new_from_book(book)

  downloader.output_directory = $config[:output] if $config[:output]

  Kindai::Util.logger.info "download #{book.title}(#{book.page} pages) to #{downloader.full_directory_path}"
  downloader.download
end

Kindai::Searcher.search(ARGV[0]).each do |l|
  download(l)
end
