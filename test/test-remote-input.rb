require_relative "helper"

class RemoteInputTest < Test::Unit::TestCase
  class WithoutCacheTest < self
    def test_open_with_block
      local_path = nil
      RemoteInput.open("https://example.com/file") do |input|
        input.local_path.parent.mkpath
        input.local_path.write("12")
        local_path = input.local_path
      end
      assert do
        not local_path.parent.exist?
      end
    end

    def test_open_with_block_raised
      local_path = nil
      assert_raise(RuntimeError.new("error in block")) do
        RemoteInput.open("https://example.com/file") do |input|
          input.local_path.parent.mkpath
          input.local_path.write("12")
          local_path = input.local_path
          raise "error in block"
        end
      end
      assert do
        not local_path.parent.exist?
      end
    end

    def test_open_without_block
      input = RemoteInput.open("https://example.com/file")
      begin
        input.local_path.parent.mkpath
        input.local_path.write("12")
        assert_equal("12", input.read)
      ensure
        input.close
      end
    end
  end
end
