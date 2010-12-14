$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'kindai'
# Kindai::Util.debug_mode

module Kernel
  private
  alias open_without_cache open
  class << self
    alias open_without_cache open
  end

  def open(name, *rest, &block)
    Kindai::Util.logger.debug "open #{name.to_s}"

    cache_directory = File.join(File.dirname(__FILE__), '..', 'spec', 'cache')
    Dir.mkdir(cache_directory) unless File.directory?(cache_directory)
    cache_file = File.join(cache_directory, Digest::SHA1.hexdigest(name.to_s))
    unless File.exists? cache_file
      Kindai::Util.logger.debug "create cache file"
      open_without_cache(cache_file, 'w') {|f|
        f.puts Marshal.dump(nameopen_without_cache())
      }
    end
    open_without_cache(cache_file, *rest, &block)
  end
  module_function :open
end
