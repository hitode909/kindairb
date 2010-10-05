# -*- coding: utf-8 -*-
module Kindai
  class Downloader
    attr_accessor :book
    attr_accessor :output_directory

    def self.new_from_book(book)
      raise TypeError, "#{book} is not Kindai::Book" unless book.is_a? Kindai::Book
      me = self.new
      me.book = book
      me
    end

    def download
      create_directory
      download_images
    end

    def directory_path
      default = [@book.author, @book.title].compact.join(' - ')
      default = @output_directory + '/' + default if @output_directory
      return default unless File.exists?(default)
      return default if File.directory?(default)
      (1..(1/0.0)).each{ |suffix|
        alter = [default, suffix].join('-')
        return alter unless File.exists?(default)
        return alter if File.directory?(default)
      }
    end

    def full_directory_path
      File.expand_path(directory_path)
    end

    protected

    # TODO: output directory
    def path_at(i)
      "#{directory_path}/#{@book.title}-#{i}.jpg"
    end

    def create_directory
      Dir.mkdir(directory_path) unless File.directory?(directory_path)
    end

    def download_images
      failed_count = 0
      threshold = 3
      (1..(1/0.0)).each { |i|
        begin
          next if has_file_at(i)
          Kindai::Util.logger.info "downloading " + [@book.author, @book.title, "koma #{i}"].join(' - ')
          Kindai::Util.download(@book.image_url_at(i), path_at(i))
        rescue Interrupt => e
          Kindai::Util.logger.error "#{e.class}: #{e.message}"
          return
        rescue Exception, TimeoutError => e
          failed_count += 1
          Kindai::Util.logger.warn "failed (#{failed_count}/#{threshold}) #{e.class}: #{e.message}"
          if failed_count >= threshold
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

    def has_file_at(i)
      File.size?(path_at(i))
    end
  end
end
