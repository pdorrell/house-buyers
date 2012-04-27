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

class GoogleSearcher
  def searchUrl(query)
    "http://www.google.com/search?as_q=#{CGI.escape(query)}"
  end
  
  def searchUrlRestricted(query, siteDomain)
    searchUrl("site:#{siteDomain} #{query}")
  end
end

$googleSearcher = GoogleSearcher.new()

class RealEstateSite
  attr_reader :name, :domain
  
  def initialize(name, domain)
    @name = name
    @domain = domain
  end
  
  def searchUrl(query)
    $googleSearcher.searchUrlRestricted(query, @domain)
  end
end

$realEstateSites = [RealEstateSite.new("TradeMe", "trademe.co.nz"), 
                    RealEstateSite.new("Open2View", "open2view.com")]

$companySites = [RealEstateSite.new("Tommys", "tommys.co.nz")]

get '/' do
  @address = params[:address]
  @addressQuery = spacified(@address)
  haml :index
end
