class ResetRepository
  def initialize(release)
    @put_object_url = release.fetch('repo_put_url')
  end

  def to_s(work_dir)
    "
    cd #{work_dir}
    mkdir -p unpack
    cd unpack
    git init --bare . >/dev/null 2>&1
    tar -zcf ../repack.tgz .
    curl --silent -o /dev/null --upload-file ../repack.tgz '#{@put_object_url}'
    "
  end
end
