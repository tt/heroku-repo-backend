require_relative '../lib/command_runner'

describe CommandRunner do
  subject { CommandRunner.new }

  context '#execute' do
    it 'writes output' do
      command = stub
      command.stub(:to_s) {|dir| 'echo foo' }
      out = mock
      out.should_receive(:write).with("foo\n")
      subject.execute(command, out, nil)
    end

    it 'writes errors' do
      command = stub
      command.stub(:to_s) {|dir| 'echo foo 1>&2' }
      err = mock
      err.should_receive(:write).with("foo\n")
      subject.execute(command, nil, err)
    end
  end
end
