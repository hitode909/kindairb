# -*- coding: utf-8 -*-
module Kindai::Util
  def self.logger
    @logger ||= Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger
  end

  def self.download(url, file)
    total = nil
    open(file, 'w') {|local|
      got = open(url,
        :content_length_proc => proc{|_total|
          total = _total
        },
        :progress_proc => proc{ |now|
          print "%3d%% #{now}/#{total}\r" % (now/total.to_f*100)
          $stdout.flush
        }
        ) {|remote|
        local.write(remote.read)
      }
    }
  rescue Exception, TimeoutError => error
    if File.exists?(file)
      logger.debug "delete cache"
      File.delete(file)
    end
    raise error
  end

  # input:  {:a => 'a', :b => 'bbb'}
  # output: 'a=a&b=bbb
  def self.expand_params(params)
    params.each_pair.map{ |k, v| [URI.escape(k.to_s), URI.escape(v.to_s)].join('=')}.join('&')
  end
end
