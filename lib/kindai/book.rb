module Kindai
  class Book
    attr_accessor :detail_url
    attr_accessor :book_id

    def self.new_from_book_id(book_id)
      me = new
      me.book_id = book_id
      me
    end

    def self.new_from_detail_url(detail_url)
      raise "not detail url" unless detail_url.match(/BIBibDetail/)
      me = new
      me.detail_url = detail_url
      me
    end

    def permalink
      @permalink ||=
        begin
          if @detail_url
            permalink_from_detail_url
          elsif @book_id
            permalink_from_book_id
          else
            raise "detail_url or book_is is required."
          end
        end
    end

    protected
    def permalink_from_book_id
      "http://kindai.da.ndl.go.jp/info:ndljp/pid/#{book_id}/1"
    end

    def permalink_from_detail_url
      detail_page = Nokogiri open(URI.escape(detail_url))
      @book_id = detail_page.at('a[href*="pid"]')['href'].scan(/(?:pid\/)(\d+)/).flatten.first
      permalink_from_book_id
    end
  end
end
