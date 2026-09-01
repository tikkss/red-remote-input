require "tmpdir"

module RemoteInput
  class TmpPath
    def initialize(id)
      @id = id
    end

    def base_dir
      Pathname(system_tmp_dir).expand_path + "red-remote-input" + @id
    end

    def remove
      FileUtils.rmtree(base_dir.to_s, secure: true) if base_dir.exist?
    end

    private

    def system_tmp_dir
      Dir.tmpdir
    end
  end
end
