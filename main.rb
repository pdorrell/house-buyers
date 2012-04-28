$stdout.sync = true

require 'bundler'
require 'sinatra'
require 'cgi'
require 'haml'

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

class GoogleMapsSearcher
  def searchUrl(query)
    "http://maps.google.com/maps?q=#{CGI.escape(query)}"
  end
  
end

$googleMapsSearcher = GoogleMapsSearcher.new()

class GoogleSearchInRegion
  attr_reader :name, :queryString
  def initialize(name, queryString)
    @name = name
    @queryString = queryString
  end
  
  def searchUrl(query)
    $googleMapsSearcher.searchUrl("#{query} #{@queryString}")
  end
end

$googleRegionSearchers = [GoogleSearchInRegion.new("Wellington", "wellington new zealand"), 
                          GoogleSearchInRegion.new("NZ", "new zealand")]

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
                    RealEstateSite.new("Open2View", "open2view.com"), 
                    RealEstateSite.new("RealEstate.co.nz", "realestate.co.nz")]

$companySites = [RealEstateSite.new("Tommys", "tommys.co.nz")]

def reduced(paramValue)
  if paramValue != nil
    paramValue = paramValue.strip
    if paramValue == ""
      paramValue = nil
    end
  end
  paramValue
end

get '/' do
  @address = reduced(params[:address])
  @addressQuery = spacified(@address)
  haml :index
end
