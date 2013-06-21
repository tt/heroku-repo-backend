class UpdateReference
  def initialize(release, sha1)
    @get_object_url = release.fetch('repo_get_url')
    @put_object_url = release.fetch('repo_put_url')
    @sha1 = sha1
  end

  def to_s(work_dir)
    "
    set -e
    curl --silent -o repo.tgz '#{@get_object_url}'
    mkdir unpack
    cd unpack
    tar -zxf ../repo.tgz
    echo -n 'Updating reference...'
    git update-ref HEAD #{@sha1} >/dev/null 2>&1 && echo ' done'
    tar -zcf ../repack.tgz .
    curl --silent -o /dev/null --upload-file ../repack.tgz '#{@put_object_url}'
    "
  end
end
