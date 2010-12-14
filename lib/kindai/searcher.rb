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
      (0..(1/0.0)).each{ |page|
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
      total = page.at('.//opensearch:totalResults', {"opensearch"=>"http://a9.com/-/spec/opensearchrss/1.0/"} ).content.to_i

      Kindai::Util.logger.debug "total: #{total}"
      total
    end

    def result_for keyword, page = 0
      page = Nokogiri Kindai::Util.fetch_uri(uri_for(keyword, page))
      page.search('item').map{ |item|
        item.at('link').content
      }
    end

    def uri_for keyword, page = 0
      count = 10
      params = { :any => keyword, :dpid => 'kindai', :idx => page * count + 1, :cnt => count}
      root = URI.parse("http://api.porta.ndl.go.jp/servicedp/opensearch")
      path = '?' + Kindai::Util.expand_params(params)
      root + path
    end
  end
end
