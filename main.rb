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

$genericSites = [RealEstateSite.new("TradeMe", "trademe.co.nz"), 
                    RealEstateSite.new("Open2View", "nz.open2view.com"), 
                    RealEstateSite.new("RealEstate.co.nz", "realestate.co.nz")]

$agencySites = [
                 RealEstateSite.new("Bayleys", "bayleys.co.nz"), 
                 RealEstateSite.new("Borders", "borders.net.nz"), 
                 RealEstateSite.new("Century 21", "century21.co.nz"), 
                 RealEstateSite.new("First National", "guardianfirstnational.co.nz"), 
                 RealEstateSite.new("Harcourts", "harcourts.co.nz"), 
                 RealEstateSite.new("Jewetts", "jewetts.co.nz"), 
                 RealEstateSite.new("Just Patterson", "justpaterson.co.nz"), 
                 RealEstateSite.new("LJ Hooker", "ljhooker.co.nz"), 
                 RealEstateSite.new("Professionals", "professionals.co.nz"), 
                 RealEstateSite.new("Ray White", "rwwellingtoncity.co.nz"), 
                 RealEstateSite.new("Remax", "leaders.co.nz"), 
                 RealEstateSite.new("Tommys", "tommys.co.nz")
                ]

$valuationSites = [
                   RealEstateSite.new("QV", "qv.co.nz"), 
                   RealEstateSite.new("Zoodle", "zoodle.co.nz"), 
                  ]

$otherSites = [
                 RealEstateSite.new("Homesell", "homesell.co.nz")
              ]

class SiteGroup
  attr_reader :title, :sites
  def initialize(title, sites)
    @title = title
    @sites = sites
  end
end

$siteGroups = [SiteGroup.new("Generic listing sites", $genericSites), 
               SiteGroup.new("Real estate agencies", $agencySites), 
               SiteGroup.new("Valuation sites", $valuationSites), 
               SiteGroup.new("Other sites", $otherSites)]

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
