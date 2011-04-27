# -*- coding: utf-8 -*-
require 'open-uri'
require 'net/http'
require 'json'
require 'ostruct'

module Kindai::Util::Database
  ENDPOINT = URI.parse 'http://gigaschema.appspot.com/hitode909/kindai.json'

  def self.items
    @items ||= JSON.parse(open(ENDPOINT).read)['data'].map{|item|
      begin
        hash = JSON.parse(item['value'])
        self.validate(hash)
        OpenStruct.new(hash)
      rescue => error
        Kindai::Util.logger.warn error
        nil
      end
    }.compact
  end

  def self.item_for_book(book)
    self.items.find{|item| item.uri == book.permalink_uri}
  end

  def self.save_item(book, info)
    previous_item = self.item_for_book(book)
    if previous_item and previous_item.version >= Kindai::VERSION
      Kindai::Util.logger.warn "Database has newer version of #{book.title}. To save, delete it first."
      return false
    end

    send_data = {
      'uri'     => book.permalink_uri,
      'title'   => book.title,
      'author'  => book.author,
      'x'       => info[:x],
      'y'       => info[:y],
      'width'   => info[:width],
      'height'  => info[:height],
      'version' => Kindai::VERSION
    }
    self.validate(send_data)

    res = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port){|http|
      request = Net::HTTP::Post.new(ENDPOINT.path)
      request.set_form_data({:value => send_data.to_json})
      http.request(request)
    }
    case res.code
    when '200'
      JSON.parse(res.body)
    else
      raise res
    end
  end

  def self.validate(info)
    %w{uri title author}.each{|key|
      raise "key #{key} is required" unless info.has_key? key
      raise "key #{key} must be kind of String" unless info[key].kind_of? String
    }

    %w{x y width height version}.each{|key|
      raise "key #{key} is required" unless info.has_key? key
      raise "key #{key} must be kind of Numeric" unless info[key].kind_of? Numeric
    }
  end
end
