#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'kindai'

if ARGV.empty?
  puts "usage: publish.rb (root path to directory)"
end

ARGV.each{|file|
  Kindai::Util.logger.info "publish #{file}"
  publisher = Kindai::Publisher.new_from_path file
  publisher.clone.trim.resize(1280, 960).trim.zip.name('iphone').publish
  publisher.clone.trim.resize(600, 800).divide.zip.name('kindle').publish
}
