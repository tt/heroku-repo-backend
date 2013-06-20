require 'heroku-api'
require 'open3'
require 'sinatra'

require './lib/event_response'
require './lib/io'
require './lib/garbage_collect'
require './lib/reset_repository'
require './lib/purge_cache'
require './lib/update_reference'

class Rack::Auth::Basic::Request
  def password; credentials.last; end
end

helpers do

  def auth
    Rack::Auth::Basic::Request.new(request.env)
  end

  def protected!
    if not auth.provided? or not auth.basic?
      halt 401, { 'WWW-Authenticate' => 'Basic realm="Heroku"' }, ''
    end
  end

  def heroku
    Heroku::API.new(:username => auth.username, :password => auth.password)
  end

  def execute(command_class)
    release = heroku.get_release(params.fetch('app'), 'new')

    params.merge!({
      'get' => release.body['repo_get_url'],
      'put' => release.body['repo_put_url']
    })

    command = command_class.new(params)

    stream(:keep_open) do |out|
      response = EventResponse.new(out)

      stdin, stdout, stderr = Open3.popen3(command.to_s)

      mapping = {
        stdout => EventResponse::IO.new('out', response),
        stderr => EventResponse::IO.new('err', response)
      }

      IO.join(mapping)

      response.close
    end
  end

end

get '/commands/gc', provides: 'text/event-stream' do
  protected!
  execute GarbageCollect
end

get '/commands/purge_cache', provides: 'text/event-stream' do
  protected!
  execute PurgeCache
end

get '/commands/reset', provides: 'text/event-stream' do
  protected!
  execute ResetRepository
end

get '/commands/update-ref', provides: 'text/event-stream' do
  protected!
  execute UpdateReference
end
