# -*- coding: utf-8 -*-
module Kindai
  class SpreadDownloader
    attr_accessor :spread
    attr_accessor :retry_count
    attr_accessor :book_path

    def self.new_from_spread(spread)
      raise TypeError, "#{spread} is not Kindai::Spread" unless spread.is_a? Kindai::Spread
      me = self.new
      me.spread = spread
      me.retry_count = 0
      me.book_path = Pathname.new(ENV["HOME"]).to_s
      me
    end

    def download
      return false if self.has_file?
      self.download_spread
      return true
    end

    def spread_path
      path = File.join self.book_path, "%03d.jpg" % self.spread.spread_number
      File.expand_path path
    end

    def delete
      return File.delete(self.spread_path) && true rescue false
    end

    def has_file?
      File.size? self.spread_path
    end

    protected

    def download_spread
      failed_count = 0

      begin
        Kindai::Util.logger.info "downloading " + [self.spread.book.author, self.spread.book.title, "spread", self.spread.spread_number].join(' - ')
        Kindai::Util.rich_download(spread.image_uri, self.spread_path)
      rescue Interrupt => err
        Kindai::Util.logger.error "#{err.class}: #{err.message}"
        exit 1
      rescue StandardError, TimeoutError => err
        Kindai::Util.logger.warn "failed (#{failed_count}/#{self.retry_count}) #{err.class}: #{err.message}"
        raise err if failed_count == self.retry_count

        Kindai::Util.logger.info "sleep and retry"
        failed_count += 1
        sleep 3
      end
    end

  end
end
