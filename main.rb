require 'sinatra'
require 'byebug'
require 'sinatra/reloader' if development?
require 'dragonfly'
require 'sportsball/assets'

Dragonfly.app.configure do
  plugin :imagemagick
end

get '/*' do |path|
  size = params[:size] ? params[:size] : '70x70'
  updated_path = Sportsball::Assets.decode_path(path.gsub(/.png/, '')).gsub('images/', '')
  Dragonfly.app.fetch_url("https://s3.amazonaws.com/jumbotron/#{updated_path}.png").thumb(size).to_response(env)
end
