$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'kindai'
require 'tmpdir'

module Kindai::Util
  def self.fetch_uri(uri, rich = false)
    logger.debug "fetch uri #{uri}"
    uri = URI.parse(uri) unless uri.kind_of? URI

    cache_directory = File.join(Dir.tmpdir, 'kindairb-cache')
    Dir.mkdir(cache_directory) unless File.directory?(cache_directory)

    cache_file = File.join(cache_directory, Digest::SHA1.hexdigest(uri.to_s))
    unless File.exists? cache_file
      logger.debug "fetch cache #{uri}"
      open(cache_file, 'w') {|f|
        f.write Marshal.dump(uri.read)
      }
    end

    Marshal.load open(cache_file).read
  end
end
