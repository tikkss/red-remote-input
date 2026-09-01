module RemoteInput
  class Input
    def initialize(url, mode="r", fallback_urls: [], **http_options)
      @downloader = Downloader.new(url, *fallback_urls, **http_options)
      validate_mode(mode)
      @mode = mode
      @tmp_path = TmpPath.new("#{Process.pid}-#{object_id}")
      @local_file = nil
      @closed = false
    end

    def read(maxlen=nil, out_string=nil)
      local_file.read(maxlen, out_string)
    end

    def close
      @local_file.close if @local_file and not @local_file.closed?
      @tmp_path.remove
      @closed = true
    end

    def local_path
      @tmp_path.base_dir + "data"
    end

    private

    def local_file
      raise IOError, "closed stream" if @closed
      return @local_file if @local_file
      @downloader.download(local_path)
      @local_file = local_path.open(@mode)
    end

    def validate_mode(mode)
      unless ["r", "rb", File::RDONLY].include?(mode)
        message = "mode must be \"r\", \"rb\" or File::RDONLY: #{mode.inspect}"
        raise ArgumentError, message
      end
    end
  end
end
