class ResetRepository
  def initialize(release)
    @put_object_url = release.fetch('repo_put_url')
  end

  def to_s
    "
    set -e
    mkdir unpack
    cd unpack
    echo -n 'Resetting repository...'
    git init --bare . >/dev/null 2>&1 && echo ' done'
    tar -zcf ../repack.tgz .
    curl --silent -o /dev/null --upload-file ../repack.tgz '#{@put_object_url}'
    "
  end
end
