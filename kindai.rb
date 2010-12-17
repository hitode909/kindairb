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
    config[:base_path] = v
  }
  opt.on('--debug', 'enable debug mode') {|v|
    Kindai::Util.debug_mode!
  }
  opt.on('--retry TIMES', 'retry times (default is 3)') {|v|
    config[:retry_count] = v.to_i
  }
  opt.parse!(ARGV)
}

unless ARGV.length > 0
  puts parser.help
  exit 1
end

# download
ARGV.each{ |arg|
  if URI.regexp =~ arg and URI.parse(arg).is_a? URI::HTTP
    Kindai::Interface.download_url arg, config
  else
    Kindai::Interface.download_keyword arg, config
  end
}
