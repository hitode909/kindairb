# -*- coding: utf-8 -*-
require 'optparse'

module Kindai
  class CLI
    BANNER = <<EOF
kindai.rb - the kindai digital library downloader

download:
    by url:     kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693
    by keyword: kindai.rb 調理法

publish:
    auto:       kindai.rb publish '~/Desktop/石川，一口；丸山，平次郎 - 講談幽霊の片袖'
    manual:     kindai.rb publish --position 2850x2450+320+380 '~/Desktop/石川，一口；丸山，平次郎 - 講談幽霊の片袖'

options:
EOF

    def self.execute(stdout, arguments=[])
      if arguments.first == 'publish'
        arguments.shift
        self.execute_publish(stdout, arguments)
      else
        self.execute_download(stdout, arguments)
      end
    end

    def self.execute_download(stdout, arguments)
      config = { }
      parser = OptionParser.new(BANNER) {|opt|
        opt.on('-o OUTPUT_DIRECTORY', '--output', 'specify output directory') {|v|
          config[:base_path] = v
        }
        opt.on('--debug', 'enable debug mode') {|v|
          Kindai::Util.debug_mode!
        }
        opt.on('--retry TIMES', 'retry times (default is 30)') {|v|
          config[:retry_count] = v.to_i
        }
        opt.on('--publish_iphone', 'publish for iphone') {|v|
          config[:publish_iphone] = true
        }
        opt.on('--publish_kindle', 'publish for kindle') {|v|
          config[:publish_kindle] = true
        }
        opt.on('--no_trimming', "don't trimming") {|v|
          config[:no_trimming] = true
        }
        opt.parse!(arguments)
      }

      if arguments.empty?
        stdout.puts parser.help
        exit 1
      end

      arguments.each{ |arg|
        if URI.regexp =~ arg and URI.parse(arg).is_a? URI::HTTP
          Kindai::Interface.download_url arg, config
        else
          Kindai::Interface.download_keyword arg, config
        end
      }
    end

    def self.execute_publish(stdout, arguments)
      config = { }
      parser = OptionParser.new(BANNER) {|opt|
        opt.on('--position TRIMMING_POSITION', 'specify trimming position (example:') {|v|
          m = v.match(/^(\d+)x(\d+)\+(\d+)\+(\d+)$/)
          unless m
            raise "invalid trimming position( example: 3200x2450+320+380, WIDTHxHEIGHT+OFFSET_X+OFFSET_Y )"
          end
          config[:trimming] = {:width => m[1].to_i, :height => m[2].to_i, :x => m[3].to_i, :y => m[4].to_i}
        }
        opt.on('--debug', 'enable debug mode') {|v|
          Kindai::Util.debug_mode!
        }
        opt.parse!(arguments)
      }

      if arguments.empty?
        stdout.puts parser.help
        exit 1
      end

      arguments.each{|file|
        Kindai::Util.logger.info "publish #{file}"
        publisher = Kindai::Publisher.new_from_path file
        publisher.empty('trim')
        publisher.empty('*zip')
        if config[:trimming]
          publisher.trim(config[:trimming])
        end
        publisher.publish_auto
      }

    end
  end
end
