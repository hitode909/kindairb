#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
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
  opt.on('-d', '--divide', 'divide image into two') {|v|
    Kindai::Util.convert_required
    config[:use_divide] = true
  }
  opt.on('-p', '--pdf', 'enable pdf generating') {|v|
    config[:use_pdf] = true
  }
  opt.on('--debug', 'enable debug mode') {|v|
    config[:debug_mode] = true
  }
  opt.on('-x X', '--trimming-x', 'left margin for trimming download') {|v|
    config[:trimming_x] = v.to_i
  }
  opt.on('-y Y', '--trimming-y', 'top margin for trimming download') {|v|
    config[:trimming_y] = v.to_i
  }
  opt.on('-w WIDTH', '--trimming-width', 'width for trimming download') {|v|
    config[:trimming_w] = v.to_i
  }
  opt.on('-h HEIGHT', '--trimming-height', 'width for trimming download') {|v|
    config[:trimming_h] = v.to_i
  }
  opt.on('-t', '--test', 'Download the first page only') {|v|
    config[:test_mode] = v
  }
  opt.parse!(ARGV)
}

Kindai::Util.debug_mode if config[:debug_mode]

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
