# -*- coding: utf-8 -*-
module Kindai
  class Searcher
    include Enumerable
    attr_accessor :keyword
    def self.search keyword
      Kindai::Util.logger.debug "keyword: #{keyword}"
      me = self.new
      me.keyword = keyword
      me
    end

    def length
      @length ||= total_of(@keyword)
    end

    def each
      (1..(1/0.0)).each{ |page|
        Kindai::Util.logger.debug "page #{page}"
        uris = result_for(@keyword, page)
        return if uris.empty?
        uris.each{ |uri|
          yield Kindai::Book.new_from_permalink(uri)
        }
      }
    end

    protected
    def total_of(keyword)
      page = Nokogiri(Kindai::Util.fetch_uri(uri_for(keyword)))
      total = page.at('.tableheadercontent-left p').content.scan(/\d+/).first.to_i

      Kindai::Util.logger.debug "total: #{total}"
      total
    end

    def result_for keyword, page = 1
      page = Nokogiri Kindai::Util.fetch_uri(uri_for(keyword, page))
      page.search('a.item-link').map{ |item|
        'http://dl.ndl.go.jp' + item.attr('href')
      }
    end

    def uri_for keyword, page = 1
      rows = 100
      params = { :SID => 'kindai', :viewRestricted => 0, :searchWord => keyword, :pageNo => page, :rows => rows }
      root = URI.parse("http://dl.ndl.go.jp/search/searchResult")
      query = '?' + Kindai::Util.expand_params(params)
      root + query
    end
  end
end
