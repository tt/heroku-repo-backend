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

  context '#close' do
    it 'closes the out' do
      EventMachine::PeriodicTimer.stub(:new) { stub.as_null_object }
      out = mock
      out.stub(:<<)
      out.should_receive(:close)
      response = EventResponse.new(out)
      response.close
    end

    it 'stops the timer' do
      timer = mock
      timer.should_receive(:cancel)
      EventMachine::PeriodicTimer.stub(:new) { timer }
      out = stub
      out.stub(:<<)
      out.stub(:close)
      response = EventResponse.new(out)
      response.close
    end

    it 'writes an event' do
      EventResponse.any_instance.should_receive(:write).with('close')
      EventMachine::PeriodicTimer.stub(:new) { stub.as_null_object }
      out = mock
      out.stub(:close)
      response = EventResponse.new(out)
      response.close
    end
  end
end
