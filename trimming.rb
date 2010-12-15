#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'kindai'

if ARGV.empty?
  puts "usage: trimming.rb (path to directory)"
end

def trimming(path)
  path = path.gsub(/\/$/, '')
  output_dir = path + '_trim'
  puts " => #{output_dir}"
  Dir.mkdir(output_dir) unless File.directory?(output_dir)

  Dir.glob(File.join(path, '*.jpg')).each{|input_path|
    output_path = File.join( output_dir, File.basename(input_path))
    next if File.exist?(output_path)
    puts output_path
    Kindai::Util.trim_file_to input_path, output_path
    GC.start
  }
end

ARGV.each{|dir_path|
  trimming dir_path
}
