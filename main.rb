require 'sinatra'
require 'byebug'
require 'sinatra/reloader' if development?
require 'dragonfly'

Dragonfly.app.configure do
  plugin :imagemagick
end

get '/*' do |path|
  size = params[:size] ? params[:size] : '70x70'
  Dragonfly.app.fetch_url("https://s3.amazonaws.com/jumbotron/#{path}.png").thumb(size).to_response(env)
end
