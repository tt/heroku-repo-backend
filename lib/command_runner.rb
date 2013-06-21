require 'fileutils'
require 'open3'
require 'tmpdir'

require './lib/io'

class CommandRunner
  def execute(command, out, err)
    work_dir = Dir.mktmpdir

    stdin, stdout, stderr = Open3.popen3(command, :chdir => work_dir)

    mapping = {
      stdout => out,
      stderr => err
    }

    IO.join(mapping)

    FileUtils.rm_r work_dir
  end
end
