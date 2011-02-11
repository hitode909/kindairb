#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'kindai'

warn 'WARNING: This script is deprecated. Use bin/kindai.rb'

Kindai::CLI.execute(STDOUT, ['publish'].concat(ARGV))
