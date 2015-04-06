require 'sinatra'
require 'raven'
require 'byebug'
require 'sinatra/reloader' if development?
require 'dragonfly'
require 'sportsball/assets'

Dragonfly.app.configure do
  plugin :imagemagick
end

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

get '/*' do |path|
  size = params[:size] ? params[:size] : '70x70'
  updated_path = Sportsball::Assets.decode_path(path.gsub(/.png/, '')).gsub('images/', '').downcase
  Dragonfly.app.fetch_url("https://s3.amazonaws.com/jumbotron/#{updated_path}.png").thumb(size).to_response(env).tap do |response|
    if response.first == 500
      Raven.capture_message "Image Failed - #{updated_path}",
        logger: 'logger',
        extra: {
          path: updated_path
        },
        tags: {
          environment: 'production'
        }
    end
  end
end
