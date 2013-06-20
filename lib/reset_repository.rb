require 'tmpdir'

class ResetRepository
  def initialize(release)
    @put_object_url = release.fetch('repo_put_url')
  end

  def to_s
    work_dir = Dir.mktmpdir
    "
    cd #{work_dir}
    mkdir -p unpack
    cd unpack
    git init --bare .
    tar -zcf ../repack.tgz .
    curl -o /dev/null --upload-file ../repack.tgz '#{@put_object_url}'
    cd ..
    rm -rf #{work_dir}
    "
  end
end
