require 'fileutils'
require 'heroku-api'
require 'open3'
require 'sinatra'
require 'tmpdir'

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
    @heroku ||= Heroku::API.new(:api_key => auth.username)
  end

  def release
    @release ||= heroku.get_release(params.fetch('app'), 'new').body
  end

  def execute(command)
    stream(:keep_open) do |out|
      response = EventResponse.new(out)

      work_dir = Dir.mktmpdir

      stdin, stdout, stderr = Open3.popen3(command.to_s(work_dir))

      mapping = {
        stdout => EventResponse::IO.new('out', response),
        stderr => EventResponse::IO.new('err', response)
      }

      IO.join(mapping)

      FileUtils.rm_r work_dir

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
