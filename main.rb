$stdout.sync = true

require 'bundler'
require 'sinatra'

get '/hi' do
  "Hola Mundo!"
end
