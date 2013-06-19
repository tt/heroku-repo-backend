require 'tempfile'

require_relative '../lib/io'

describe IO, '::join' do
  it 'writes what it reads' do
    input = File.open(__FILE__)
    Tempfile.open('output') do |output|
      IO.join({ input => output })
      input.rewind
      output.rewind
      output.read.should == input.read
    end
  end
end
