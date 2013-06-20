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
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
  end

  def protected!
    if not auth.provided? or not auth.basic?
      halt 401, { 'WWW-Authenticate' => 'Basic realm="Heroku"' }, ''
    end
  end

  def heroku
    @heroku ||= Heroku::API.new(:username => auth.username, :password => auth.password)
  end

  def release
    @release ||= heroku.get_release(params.fetch('app'), 'new').body
  end

  def arguments
    params.merge({
      'get' => release['repo_get_url'],
      'put' => release['repo_put_url']
    })
  end

  def execute(command)
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
  execute GarbageCollect.new(release)
end

get '/commands/purge_cache', provides: 'text/event-stream' do
  protected!
  execute PurgeCache.new(release)
end

get '/commands/reset', provides: 'text/event-stream' do
  protected!
  execute ResetRepository.new(release)
end

get '/commands/update-ref', provides: 'text/event-stream' do
  protected!
  execute UpdateReference.new(release, params.fetch('sha1'))
end
