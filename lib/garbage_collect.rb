class GarbageCollect
  def initialize(release)
    warn release.inspect
    @get_object_url = release.fetch('repo_get_url')
    @put_object_url = release.fetch('repo_put_url')
  end

  def to_s(work_dir)
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
    command
  end
end
