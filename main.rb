$stdout.sync = true

require 'bundler'
require 'sinatra'

set :haml, :format => :html5

get '/' do
  @address = params[:address]
  haml :index
end
