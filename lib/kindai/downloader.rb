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

    def retry_count
      @retry_count || 3
    end

    def retry_count=(x)
      Kindai::Util.logger.info "retry_count = #{x}"
      @retry_count = x
    end

    protected

    # TODO: output directory
    def path_at(i)
      "#{directory_path}/%03d.jpg" % i
    end

    def create_directory
      Dir.mkdir(directory_path) unless File.directory?(directory_path)
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
