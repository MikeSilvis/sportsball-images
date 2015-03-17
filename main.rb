require 'sinatra'
require 'byebug'
require 'sinatra/reloader' if development?
require 'dragonfly'

Dragonfly.app.configure do
  plugin :imagemagick
end

class QueryBase
  ASSET_STRINGS = [
    'ASSET_STRING_1',
    'ASSET_STRING_2'
  ]
  ASSET_HASHES = ASSET_STRINGS.map do |asset_string|
    Digest::MD5.hexdigest(asset_string)
  end

  def self.decode_path(path)
    path.tap do |updated_path|
      ASSET_HASHES.each do |asset_hash|
        updated_path.gsub!("-#{asset_hash}", '')
      end
    end
  end
end

get '/*' do |path|
  size = params[:size] ? params[:size] : '70x70'
  updated_path = QueryBase.decode_path(path.gsub(/.png/, ''))
  Dragonfly.app.fetch_url("https://s3.amazonaws.com/jumbotron/#{updated_path}.png").thumb(size).to_response(env)
end
