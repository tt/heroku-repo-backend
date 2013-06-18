require 'base64'
require 'open3'
require 'sinatra'

require './lib/event_response'
require './lib/garbage_collect'
require './lib/reset_repository'
require './lib/purge_cache'

get '/commands/*', provides: 'text/event-stream' do
  command_class = case params.fetch('splat').first
                  when 'gc'          then GarbageCollect
                  when 'reset'       then ResetRepository
                  when 'purge_cache' then PurgeCache
                  end

  not_found if command_class.nil?

  command = command_class.new(params)

  stream(:keep_open) do |out|
    response = EventResponse.new(out)

    stdin, stdout, stderr = Open3.popen3(command.to_s)

    reads = [stdout, stderr]

    mapping = {
      stdout => 'out',
      stderr => 'err'
    }

    while reads.length > 0
      (inputs, _, _) = IO.select(reads)

      inputs.each do |input|
        if input.eof?
          reads.delete(input)
          break
        end

        bytes = input.read_nonblock(1024)

        response.write mapping.fetch(input), Base64.strict_encode64(bytes)
      end
    end

    response.close
  end
end
