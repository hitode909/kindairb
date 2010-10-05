# -*- coding: utf-8 -*-
module Kindai
  class Book
    attr_accessor :detail_url
    attr_accessor :book_id

    def self.new_from_detail_url(detail_url)
      raise "not BIBilDetail" unless detail_url.match(/BIBibDetail/)
      me = new
      me.detail_url = detail_url
      me
    end

    def permalink
      @permalink ||=
        begin
          @book_id = detail_page.at('a[href*="pid"]')['href'].scan(/(?:pid\/)(\d+)/).flatten.first
          "http://kindai.da.ndl.go.jp/info:ndljp/pid/#{book_id}/"
        end
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
          base = Nokogiri::HTML open(permalink)

          page_url = URI.parse(permalink) + base.at('frame[name="W_BODY"]')['src']

          # リダイレクトさき
          page_file = open(page_url.to_s)

          # でかいがぞうがあるページのURL
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

    def detail_page
      @detail_page ||=
        begin
          Kindai::Util.logger.debug "fetch detail page"
          page = open(detail_url) rescue open(URI.escape(detail_url))
          Nokogiri page
        end
    end

  end
end
