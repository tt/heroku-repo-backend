require 'tmpdir'

class GarbageCollect
  def initialize(params={})
    @get_object_url = params.fetch('get')
    @put_object_url = params.fetch('put')
  end

  def to_s
    work_dir = Dir.mktmpdir
    "
    cd #{work_dir}
    curl -o repo.tgz '#{@get_object_url}'
    mkdir unpack
    cd unpack
    tar -zxf ../repo.tgz
    #{capture('git gc --aggressive')}
    tar -zcf ../repack.tgz .
    curl -o /dev/null --upload-file ../repack.tgz '#{@put_object_url}'
    cd ..
    rm -rf #{work_dir}
    "
  end

  private

  def capture(command)
    "script -q /dev/null #{command}" if RUBY_PLATFORM.downcase.include?('darwin')
    "script -q -c '#{command}' /dev/null"
  end
end
