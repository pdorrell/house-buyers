$stdout.sync = true

require 'bundler'
require 'sinatra'
require 'cgi'

set :haml, :format => :html5

def googleSearchUrl(query)
  return "http://www.google.com/search?as_q=#{CGI.escape(query)}"
end

def spacified(text)
  return text
end

get '/' do
  @address = params[:address]
  @googleSearchUrl = googleSearchUrl(spacified(@address))
  haml :index
end
