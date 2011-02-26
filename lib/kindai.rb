# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'nkf'
require 'logger'
require 'open-uri'
require 'cgi'
require 'pathname'
require 'fileutils'

module Kindai
  VERSION = File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip

  require 'kindai/cli'
  require 'kindai/util'
  require 'kindai/book'
  require 'kindai/spread'
  require 'kindai/book_downloader'
  require 'kindai/spread_downloader'
  require 'kindai/searcher'
  require 'kindai/interface'
  require 'kindai/publisher'
end
