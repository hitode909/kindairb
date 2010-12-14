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
      return if self.has_file?

      self.download_spread
    end

    def spread_path
      path = File.join self.book_path, "%03d.jpg" % self.spread.spread_number
      File.expand_path path
    end

    protected

    def download_spread
      failed_count = 0

      begin
        Kindai::Util.logger.info "downloading " + [@book.author, @book.title, "koma #{i}"].join(' - ')
        Kindai::Util.rich_download(self.spread_path, spread.image_uri)
      rescue Interrupt => err
        Kindai::Util.logger.error "#{err.class}: #{err.message}"
        exit 1
      rescue StandardError, TimeoutError => err
        failed_count += 1
        Kindai::Util.logger.warn "failed (#{failed_count}/#{self.retry_count}) #{e.class}: #{e.message}"

        raise err if failed_count == self.retry_count

        Kindai::Util.logger.info "sleep and retry"
        sleep 3
      end
    end

    def has_file?
      File.size? self.spread_path
    end
  end
end
