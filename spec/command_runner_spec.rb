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
  end
end
