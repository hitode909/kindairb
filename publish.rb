#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'kindai'
require 'optparse'

# parse option
banner = <<EOF
auto publish:   ruby publish.rb '~/kindai/石川，一口；丸山，平次郎 - 講談幽霊の片袖'
manual publish: ruby publish.rb --position 2850x2450+320+380 '~/kindai/石川，一口；丸山，平次郎 - 講談幽霊の片袖'
EOF

config = { }
parser = OptionParser.new(banner) {|opt|
  opt.on('--position TRIMMING_POSITION', 'specify trimming position (example:') {|v|
    m = v.match(/^(\d+)x(\d+)\+(\d+)\+(\d+)$/)
    unless m
      raise "invalid trimming position( example: 3200x2450+320+380, WIDTHxHEIGHT+OFFSET_X+OFFSET_Y )"
    end
    config[:trimming] = {:width => m[1].to_i, :height => m[2].to_i, :x => m[3].to_i, :y => m[4].to_i}
  }
  opt.on('--debug', 'enable debug mode') {|v|
    Kindai::Util.debug_mode!
  }
  opt.parse!(ARGV)
}

if ARGV.empty?
  puts "usage: publish.rb (root path to directory)"
end

ARGV.each{|file|
  Kindai::Util.logger.info "publish #{file}"
  publisher = Kindai::Publisher.new_from_path file
  publisher.empty('trim')
  publisher.empty('*zip')
  if config[:trimming]
    publisher.trim(config[:trimming])
  end
  publisher.publish_auto
}
