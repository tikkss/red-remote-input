require_relative "remote_input/cache-path"
require_relative "remote_input/downloader"
require_relative "remote_input/input"
require_relative "remote_input/tmp-path"
require_relative "remote_input/zip-extractor"

module RemoteInput
  class << self
    def open(...)
      input = Input.new(...)
      if block_given?
        begin
          yield(input)
        ensure
          input.close
        end
      else
        input
      end
    end
  end
end
