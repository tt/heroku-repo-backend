require 'tmpdir'

class ResetRepository
  def initialize(params={})
    @put_object_url = params.fetch('put')
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
