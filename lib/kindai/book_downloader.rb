# -*- coding: utf-8 -*-
module Kindai
  class BookDownloader
    attr_accessor :book
    attr_accessor :retry_count
    attr_accessor :base_path

    def self.new_from_book(book)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
      me = self.new
      me.book = book
      me.retry_count = 0
#      me.base_path = Pathname.new(ENV["HOME"]).to_s
      me
    end

    def download
      create_directory
      download_spreads
    end

    def book_path
      path = File.join(self.base_path, [@book.author, @book.title].compact.join(' - '))
      File.expand_path path
    end

    protected

    def create_directory
      Dir.mkdir(book_path) unless File.directory?(book_path)
    end

    def download_spreads
      self.book.spreads.each{|spread|
        dl = Kindai::SpreadDownloader.new_from_spread(spread)
        dl.retry_count = self.retry_count
        dl.download_to_path(self.book_path)
      }
    end

    # --------------------------------------------------------------------

    # TODO: output directory
    def path_at(i)
      "#{directory_path}/%03d.jpg" % i
    end


    def download_images
      (1..(1/0.0)).each { |i|
        failed_count = 0
        begin
          if @test_mode
            File.delete(path_at(i)) if File.exists?(path_at(i))
            File.delete(Kindai::Util.append_suffix(path_at(i), '0')) if File.exists?(Kindai::Util.append_suffix(path_at(i), '0'))
            File.delete(Kindai::Util.append_suffix(path_at(i), '1')) if File.exists?(Kindai::Util.append_suffix(path_at(i), '1'))
          end
          # XXX
          if @use_divide
            next if has_divided_file_at(i)
            Kindai::Util.logger.info "downloading " + [@book.author, @book.title, "koma #{i}"].join(' - ')
            Kindai::Util.rich_download(@book.image_url_at(i), path_at(i)) unless has_whole_file_at(i)
            unless Kindai::Util.check_file path_at(i)
              File.delete path_at(i)
              raise 'failed to download'
            end
            files = Kindai::Util.divide(path_at(i))
            if @resize_option
              files.each{|path|
                Kindai::Util.logger.info "resize #{path}"
                system "convert -geometry #{@resize_option} '#{path}' '#{path}'"
              }
            end
          else
            next if has_whole_file_at(i)
            Kindai::Util.logger.info "downloading " + [@book.author, @book.title, "koma #{i}"].join(' - ')
            Kindai::Util.download(@book.image_url_at(i), path_at(i))
            unless Kindai::Util.check_file path_at(i)
              File.delete path_at(i)
              raise 'failed to download'
            end
            if @resize_option
              files.each{|path|
                Kindai::Util.logger.info "resize #{path_at(i)}"
                system "convert -geometry #{@resize_option} '#{path_at(i)}' '#{path_at(i)}'"
              }
            end
          end
          return if @test_mode
        rescue Interrupt => e
          Kindai::Util.logger.error "#{e.class}: #{e.message}"
          exit 1
        rescue Exception, TimeoutError => e
          failed_count += 1
          Kindai::Util.logger.warn "failed (#{failed_count}/#{retry_count}) #{e.class}: #{e.message}"
          if failed_count >= retry_count
            Kindai::Util.logger.info "done"
            return
          else
            Kindai::Util.logger.info "sleep and retry"
            sleep 3
            retry
          end
        end
      }
    end
  end
end
