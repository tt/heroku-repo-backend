class GarbageCollect
  def initialize(release)
    @get_object_url = release.fetch('repo_get_url')
    @put_object_url = release.fetch('repo_put_url')
  end

  def to_s(work_dir)
    "
    set -e
    cd #{work_dir}
    curl --silent -o repo.tgz '#{@get_object_url}'
    mkdir unpack
    cd unpack
    tar -zxf ../repo.tgz
    echo -n 'Compressing repository...'
    git gc --aggressive >/dev/null 2>&1 && echo ' done'
    tar -zcf ../repack.tgz .
    curl --silent -o /dev/null --upload-file ../repack.tgz '#{@put_object_url}'
    "
  end
end
