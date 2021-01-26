require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/content_for'
require 'json'
# require 'pry'

require_relative 'models/pipotron'

class App < Sinatra::Base
  register Sinatra::ConfigFile
  helpers Sinatra::ContentFor
  config_file 'config/settings/pipotron.yml'

  get '/' do
    erb "/collections/#{settings.pipotron[:slug]}".to_sym, layout: "/layouts/#{settings.pipotron[:slug]}".to_sym
  end

  get '/about' do
    erb "/about/#{settings.pipotron[:slug]}".to_sym, layout: "/layouts/#{settings.pipotron[:slug]}".to_sym
  end

  get '/generate' do
    content_type :json, 'charset' => 'utf-8'
    pipo = ''
    indexes = []

    # Pipo Message
    settings.schema.each do |seq|
      i = (0...settings.send(seq).count).to_a.sample

      pipo << "#{settings.send(seq)[i]} "
      indexes << i
    end

    # Pipo Profile
    profile_pic_id = "%02d" % (1..(settings.pipotron[:profiles])).to_a.sample
    profile_pic_path = "/images/profiles/#{settings.pipotron[:slug]}/#{profile_pic_id}.jpg"
    indexes << profile_pic_id.to_i

    {
      pipo: pipo,
      profile: {
        pic: profile_pic_path
      },
      hash: Pipotron.indexes_to_hash(indexes),
      button: settings.button_labels.sample
    }.to_json
  end

  get '/pipo/:hash' do
    indexes = Pipotron.hash_to_indexes(params['hash'])
    @pipo = {
      message: '',
      hash: params['hash']
    }

    settings.schema.each_with_index do |seq, i|
      @pipo[:message] << "#{settings.send(seq)[indexes[i]]} "
    end

    profile_pic_id = "%02d" % indexes.last
    @pipo[:profile_pic_path] = "/images/profiles/#{settings.pipotron[:slug]}/#{profile_pic_id}.jpg"

    erb "/members/#{settings.pipotron[:slug]}".to_sym, layout: "/layouts/#{settings.pipotron[:slug]}".to_sym
  end

  run! if app_file == $0
end
