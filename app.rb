require 'heroku-api'
require 'sinatra'

require './lib/command_runner'
require './lib/event_response'
require './lib/garbage_collect'
require './lib/reset_repository'
require './lib/purge_cache'
require './lib/update_reference'

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
    @heroku ||= Heroku::API.new(:api_key => auth.username)
  end

  def release
    @release ||= heroku.get_release(params.fetch('app'), 'new').body
  end

  def execute(command)
    stream(:keep_open) do |out|
      response = EventResponse.new(out)

      out = EventResponse::IO.new('out', response)
      err = EventResponse::IO.new('err', response)

      CommandRunner.new.execute(command, out, err)

      response.close
    end
  end

end

get '/commands/gc', :provides => 'text/event-stream' do
  protected!
  execute GarbageCollect.new(release)
end

get '/commands/purge_cache', :provides => 'text/event-stream' do
  protected!
  execute PurgeCache.new(release)
end

get '/commands/reset', :provides => 'text/event-stream' do
  protected!
  execute ResetRepository.new(release)
end

get '/commands/update-ref', :provides => 'text/event-stream' do
  protected!
  execute UpdateReference.new(release, params.fetch('sha1'))
end
