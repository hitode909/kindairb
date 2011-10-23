# -*- coding: utf-8 -*-
module Kindai
  class Book
    attr_accessor :permalink_uri
    attr_accessor :trimming

    # ----- constructor -----
    def self.new_from_permalink(permalink_uri, trimming = {})
      raise "not info:ndljp" unless permalink_uri.match(/info\:ndljp/)
      me = new
      me.permalink_uri = permalink_uri
      me.trimming = trimming
      return me
    end

    def self.new_from_local_directory(path)
      metadata = File.join(path, 'metadata')
      permalink = open(metadata).read.chomp
      return self.new_from_permalink(permalink)
    end

    # ----- metadata -----

    def key
      permalink_uri.match(/\d+$/)[0]
    end

    def title
      title_container = control_page.at('.titlehead')
      subtitle_container = control_page.at('.headmenu')
      title_string = title_container.content.strip
      title_string += subtitle_container.content.strip if subtitle_container
      title_string
    end

    def author
      metadata['著者標目']
    end

    def total_spread
      self.spread_at(1).page.search('select#dlPages option').length
    end

    def spreads
      @spreads ||= 1.upto(self.total_spread).map{|i| self.spread_at(i) }
    end

    def base_uri
      @base_uri ||=
        begin
          Kindai::Util.logger.debug "fetch permalink page"
          page_uri = URI.parse(permalink_uri) + permalink_page.at('frame[name="W_BODY"]')['src']

          page_base_uri = Kindai::Util.get_redirected_uri page_uri.to_s
          uri = page_base_uri.to_s + '&vs=10000,10000,0,0,0,0,0,0'
          unless self.trimming.keys.empty?
            %w{x y w h resize_w resize_h}.map(&:to_sym).each{ |key|
              self.trimming[key] ||= 0
            }
            uri += "&ref=" + [self.trimming[:x], self.trimming[:y], self.trimming[:w], self.trimming[:h], self.trimming[:resize_w], self.trimming[:resize_h], 0, 0].join(',')
          end
          uri
        end
    end

    protected

    def spread_at(spread_number)
      Kindai::Spread.new_from_book_and_spread_number(self, spread_number)
    end

    def metadata
      @metadata ||=
        begin
          metadata_table = detail_page.search('table').find{ |table|
            table.at('td').text == 'タイトル'
        }
          metadata_table.search('tr').inject({ }) { |prev, tr|
            key, _, value = *tr.search('td').map{ |elem| elem.text }
            prev[key] = value
            prev
          }
        end
    end

    # ----- pages -----
    def permalink_page
      @permalink_page ||=
        begin
          Kindai::Util.logger.debug "fetch permalink page"
          page = Kindai::Util.fetch_uri permalink_uri rescue Kindai::Util.fetch_uri URI.escape(permalink_uri)
          Nokogiri page
        end
    end

    def detail_uri
      root = URI.parse('http://kindai.ndl.go.jp/BIBibDetail.php')
      params = { }
      control_page.search('input').each{ |input|
        params[input['name']] = input['value'] if input['value']
      }
      path = '?' + params.each_pair.map{ |k, v| [URI.escape(k), URI.escape(v)].join('=')}.join('&')
      root + path
    end

    def detail_page
      @detail_page ||=
        begin
          Kindai::Util.logger.debug "fetch detail page"
          page = Kindai::Util.fetch_uri detail_uri rescue Kindai::Util.fetch_uri URI.escape(detail_uri)
          Nokogiri page
        end
    end

    def control_uri
      URI.parse(permalink_uri) + permalink_page.at('frame[name="W_CONTROL"]')['src']
    end

    def control_page
      @control_page ||=
        begin
          Kindai::Util.logger.debug "fetch permalink page"
          Nokogiri Kindai::Util.fetch_uri control_uri
        end
    end

  end
end
