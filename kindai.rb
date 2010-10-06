#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift('lib')
require 'kindai'
require 'optparse'

# parse option
banner = <<EOF
download by url:     ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693
download by keyword: ruby kindai.rb 調理法
EOF
config = { }
parser = OptionParser.new(banner) {|opt|
  opt.on('-o OUTPUT_DIRECTORY', '--output', 'specify output directory') {|v|
    config[:output_directory] = v
  }
  opt.parse!(ARGV)
}

# validate argv
unless ARGV.length > 0
  puts parser.help
  exit 1
end

# download
# TODO: AND検索
ARGV.each{ |arg|
  if URI.regexp =~ arg and URI.parse(arg).is_a? URI::HTTP
    Kindai::Interface.download_url arg, config
  else
    Kindai::Interface.download_keyword arg, config
  end
}
