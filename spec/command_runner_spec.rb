require_relative '../lib/command_runner'

describe CommandRunner do
  subject { CommandRunner.new }

  context '#execute' do
    it 'writes output' do
      out = mock
      out.should_receive(:write).with("foo\n")
      subject.execute('echo foo', out, nil)
    end

    it 'writes errors' do
      err = mock
      err.should_receive(:write).with("foo\n")
      subject.execute('echo foo 1>&2', nil, err)
    end

    it 'removes work directory' do
      Dir.stub(:mktmpdir) { '/tmp' }
      FileUtils.should_receive(:rm_r).with('/tmp')
      IO.stub(:join)
      Open3.stub(:popen3)
      command = stub
      command.stub(:to_s)
      subject.execute(command, nil, nil)
    end
  end
end
