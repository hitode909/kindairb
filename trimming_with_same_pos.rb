#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'kindai'

if ARGV.empty?
  puts "usage: trimming.rb (path to directory)"
end

def trimming(path)
  path = path.gsub(/\/$/, '')

  files = Dir.glob(File.join(path, '*.jpg'))
  positions = {}
  files.each{|input_path|
    pos = Kindai::Util.trim_info(input_path)
    key = [(pos[:x] / pos[:y] * 100).to_i, (pos[:width] / pos[:height] * 100).to_i]
    positions[key] = [] unless positions.has_key? key
    positions[key] << pos
    p positions.keys
    GC.start
  }

  good_pos = positions.values.sort_by{|a| a.length}.last.first
  p positions.values.sort_by{|a| a.length}.last

  output_dir = path + '_trim'
  puts " => #{output_dir}"
  Dir.mkdir(output_dir) unless File.directory?(output_dir)

  files.each{|input_path|
    next if rand > 0.3
    output_path = File.join(output_dir, File.basename(input_path))
    next if File.exist?(output_path)
    puts output_path
    Kindai::Util.trim_file_to input_path, output_path, good_pos
    GC.start
  }
end

ARGV.each{|dir_path|
  trimming dir_path
}
