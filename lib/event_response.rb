require 'eventmachine'

class EventResponse
  def initialize(out)
    @out = out
    @timer = EventMachine::PeriodicTimer.new(1) { write('heartbeat') }
  end

  def write(event, data='')
    @out << "data: #{data}\nevent: #{event}\n\n"
  end

  def close
    @timer.cancel
    write('close')
    @out.close
  end

  class IO
    def initialize(event, response)
      @event = event
      @response = response
    end

    def write(data)
      @response.write(@event, data)
    end
  end
end
