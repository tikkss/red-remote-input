require_relative "helper"

class InputTest < Test::Unit::TestCase
  def test_valid_mode
    input = RemoteInput::Input.new("https://example.com/file", "rb")
    assert_equal("rb", input.instance_variable_get(:@mode))
  end

  def test_invalid_mode
    message = "mode must be \"r\", \"rb\" or File::RDONLY: \"wb\""
    assert_raise(ArgumentError.new(message)) do
      RemoteInput::Input.new("https://example.com/file", "wb")
    end
  end

  class WithoutCacheTest < self
    def setup
      @input = RemoteInput::Input.new("https://example.com/file")
      begin
        yield
      ensure
        @input.close
      end
    end

    def test_local_path
      tmp_path = RemoteInput::TmpPath.new("#{Process.pid}-#{@input.object_id}")
      assert_equal(tmp_path.base_dir + "data", @input.local_path)
    end

    def test_read_once
      @input.local_path.parent.mkpath
      @input.local_path.write("12")
      assert_equal("12", @input.read)
    end

    def test_read_twice
      @input.local_path.parent.mkpath
      @input.local_path.write("12")
      assert_equal("1", @input.read(1))
      assert_equal("2", @input.read(1))
    end

    def test_read_after_close
      @input.close
      assert_raise(IOError.new("closed stream")) do
        @input.read
      end
    end

    def test_close_deletes_local_path
      @input.local_path.parent.mkpath
      @input.local_path.write("12")
      @input.close
      assert do
        not @input.local_path.parent.exist?
      end
    end
  end
end
