require_relative '../lib/event_response'

describe EventResponse do
  context '#initialize' do
    it 'starts a timer' do
      EventMachine::PeriodicTimer.should_receive(:new)
      response = EventResponse.new(stub)
    end

    it 'starts a timer that writes a heartbeat' do
      EventResponse.any_instance.should_receive(:write).with('heartbeat')
      EventMachine::PeriodicTimer.stub(:new) do |interval, &block|
        block.call
      end
      response = EventResponse.new(stub)
    end
  end

  context '#write' do
    before do
      EventMachine::PeriodicTimer.stub(:new)
    end

    it 'writes events with content' do
      out = mock
      out.should_receive(:<<).with("data: Hello World\nevent: message\n\n")
      response = EventResponse.new(out)
      response.write('message', 'Hello World')
    end

    it 'writes events without content' do
      out = mock
      out.should_receive(:<<).with("data: \nevent: poke\n\n")
      response = EventResponse.new(out)
      response.write('poke')
    end
  end
end
