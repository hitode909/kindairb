# -*- coding: utf-8 -*-
module Kindai
  class Book

    # ----- constructor -----
    def self.new_from_permalink(permalink_uri)
      raise "not info:ndljp: #{permalink_uri}" unless permalink_uri.match(/info\:ndljp/)
      me = new
      me.instance_eval {
        @permalink_uri = permalink_uri
      }
      return me
    end

    def self.new_from_local_directory(path)
      metadata = File.join(path, 'metadata')
      permalink = open(metadata).read.chomp
      return self.new_from_permalink(permalink)
    end

    # ----- metadata -----

    def permalink_uri
      @permalink_uri
    end

    def key
      permalink_uri.match(/\d+$/)[0]
    end

    def title
      main = metadata_like 'title'

      sub = metadata_like('volumeTranscription').to_i.to_s rescue nil
      sub ? main + sub : main
    end

    def author
      metadata_like 'creator:NDLNH'
    rescue
      alt_author
    end
    
    def alt_author
      metadata_like 'creator'
    rescue
      metadata_like 'publisher'
    end

    def total_spread
      permalink_page.search('#sel-content-no option').length
    end

    def spreads
      @spreads ||= 1.upto(self.total_spread).map{|i| self.spread_at(i) }
    end

    protected

    def metadata_like query
      query_regexp = Regexp.new(Regexp.quote("(#{ query })"))
      key = metadata.keys.find{ |key|
        key =~ query_regexp
      }
      raise "metadata like #{query} not found" unless key
      metadata[key]
    end

    def spread_at(spread_number)
      Kindai::Spread.new_from_book_and_spread_number(self, spread_number)
    end

    def metadata
      @metadata ||=
        begin
          dts = permalink_page.search('dl.detail-metadata-list dt').map{ |tag| tag.text }
          dds = permalink_page.search('dl.detail-metadata-list dd').map{ |tag| tag.text }
          dts.zip(dds).inject({ }) { |table, tupple|
            table[tupple.first.strip] = tupple.last.strip
            table
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

  end
end
