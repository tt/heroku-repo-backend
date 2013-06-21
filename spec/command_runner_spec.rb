require_relative '../lib/command_runner'

describe CommandRunner do
  subject { CommandRunner.new }

  context '#execute' do
    it 'writes output' do
      command = 'echo foo'
      out = mock
      out.should_receive(:write).with("foo\n")
      subject.execute(command, out, nil)
    end

    it 'writes errors' do
      command = 'echo foo 1>&2'
      err = mock
      err.should_receive(:write).with("foo\n")
      subject.execute(command, nil, err)
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
