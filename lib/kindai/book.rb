# -*- coding: utf-8 -*-
module Kindai
  class Book
    attr_accessor :permalink_url

    def self.new_from_permalink(permalink_url)
      raise "not info:ndljp" unless permalink_url.match(/info\:ndljp/)
      me = new
      me.permalink_url = permalink_url
      me
    end

    # attributes
    def title
      metadata['タイトル']
    end

    def author
      metadata['著者標目']
    end

    def page
      NKF.nkf("-m0Z1", metadata['形態'].scan(/^(.*)(?:ｐ)/).flatten.first).to_i
    rescue
      metadata['形態'].scan(/^(.*)(?:ｐ)/).flatten.first
    end

    def image_url_at(i)
      image = image_page_at(i).at("img#imMain")
      raise "image not found" unless image
      image['src']
    end

    protected
    def base_page_url
      @image_page_url ||=
        begin
          Kindai::Util.logger.debug "fetch permalink page"
          page_url = URI.parse(permalink_url) + permalink_page.at('frame[name="W_BODY"]')['src']

          page_file = open(page_url.to_s)
          page_file.base_uri.to_s + '&vs=5000,5000,0,0,0,0,0,0'
        end
    end

    def image_page_at(i)
      page_url = base_page_url
      page_url.gsub!(/koma=(\d+)/) { "koma=#{i}" }
      Nokogiri::HTML open(page_url)
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

    # permalink_url = @permalink_url

    def permalink_page
      @permalink_page ||=
        begin
          Kindai::Util.logger.debug "fetch permalink page"
          page = open(permalink_url) rescue open(URI.escape(permalink_url))
          Nokogiri page
        end
    end

    def detail_url
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
          page = open(detail_url) rescue open(URI.escape(detail_url))
          Nokogiri page
        end
    end

    def control_url
      URI.parse(permalink_url) + permalink_page.at('frame[name="W_CONTROL"]')['src']
    end

    def control_page
      @control_page ||=
        begin
          Kindai::Util.logger.debug "fetch permalink page"
          Nokogiri open(control_url)
        end
    end

  end
end
