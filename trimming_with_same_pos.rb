#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'kindai'

class Array
  def average
    inject{|a, b| a + b} / length.to_f
  end

end

if ARGV.empty?
  puts "usage: trimming.rb (path to directory)"
end

def trimming(path)
  path = path.gsub(/\/$/, '')

  files = Dir.glob(File.join(path, '*.jpg'))
  positions = {:x => [], :y => [], :width => [], :height => []}
  files.each{|input_path|
    pos = Kindai::Util.trim_info(input_path)

    [:x, :y, :width, :height].each{|key|
      positions[key] << pos[key]
    }

    GC.start
  }

  good_pos = {}
  [:x, :y, :width, :height].each{|key|
    good_pos[key] = positions[key].average
  }

  output_dir = path + '_trim'
  puts " => #{output_dir}"
  Dir.mkdir(output_dir) unless File.directory?(output_dir)

  files.each{|input_path|
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
