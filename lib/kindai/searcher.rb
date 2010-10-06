# -*- coding: utf-8 -*-
module Kindai
  module Searcher
    def self.search keyword
      total = total_of(keyword)
      Kindai::Util.logger.info "keyword: #{keyword}"
      Kindai::Util.logger.info "total:   #{total}"
      current = 0
      (0..(1/0.0)).each{ |page|
        Kindai::Util.logger.debug "page #{page}"
        urls = result_for(keyword, page)
        return if urls.empty?
        urls.each{ |url|
          current += 1
          yield url, current, total
        }
      }
    end

    protected
    def self.total_of(keyword)
      page = Nokogiri open(url_for(keyword))
      page.at('totalresults').text.to_i
    end

    def self.result_for keyword, page = 0
      page = Nokogiri open(url_for(keyword, page))
      page.search('item').map{ |item|
        item.at('link').next.text
      }
    end

    def self.url_for keyword, page = 0
      count = 10
      params = { :any => keyword, :dpid => 'kindai', :idx => page * count + 1, :cnt => count}
      root = URI.parse("http://api.porta.ndl.go.jp/servicedp/opensearch")
      path = '?' + Kindai::Util.expand_params(params)
      root + path
    end
  end
end
