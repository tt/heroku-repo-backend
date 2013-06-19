require 'base64'
require 'heroku-api'
require 'open3'
require 'sinatra'

require './lib/event_response'
require './lib/garbage_collect'
require './lib/reset_repository'
require './lib/purge_cache'

class Rack::Auth::Basic::Request
  def password; credentials.last; end
end

get '/commands/*', provides: 'text/event-stream' do
  auth = Rack::Auth::Basic::Request.new(request.env)

  if not auth.provided? or not auth.basic?
    halt 401, { 'WWW-Authenticate' => 'Basic realm="Heroku"' }, ''
  end

  command_class = case params.fetch('splat').first
                  when 'gc'          then GarbageCollect
                  when 'reset'       then ResetRepository
                  when 'purge_cache' then PurgeCache
                  end

  not_found if command_class.nil?

  heroku = Heroku::API.new(:username => auth.username, :password => auth.password)

  release = heroku.get_release(params.fetch('app'), 'new')

  params = {
    'get' => release.body['repo_get_url'],
    'put' => release.body['repo_put_url']
  }

  command = command_class.new(params)

  stream(:keep_open) do |out|
    response = EventResponse.new(out)

    stdin, stdout, stderr = Open3.popen3(command.to_s)

    mapping = {
      stdout => 'out',
      stderr => 'err'
    }

    reads = mapping.keys

    while reads.length > 0
      (inputs, _, _) = IO.select(reads)

      inputs.each do |input|
        if input.eof?
          reads.delete(input)
          break
        end

        bytes = input.read_nonblock(1024)

        output = mapping.fetch(input)
        response.write output, Base64.strict_encode64(bytes)
      end
    end

    response.close
  end
end
