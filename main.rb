$stdout.sync = true

require 'bundler'
require 'sinatra'
require 'cgi'
require 'haml'

set :haml, :format => :html5

def queryUrl(baseUrl, paramsHash)
  if paramsHash.empty?
    baseUrl
  else
    keysAndValues = paramsHash.keys.map { |key| "#{key}=#{CGI.escape(paramsHash[key])}" }
    "#{baseUrl}?#{keysAndValues.join("&")}"
  end
end

helpers do
  def link_with_params(body, baseUrl, paramsHash)
    url = queryUrl(baseUrl, paramsHash)
    "<a href=\"#{url}\">#{body}</a>"
  end
end

def spacified(text)
  return text
end

class GoogleSearcher
  def searchUrl(query)
    queryUrl("http://www.google.com/search", :q => CGI.escape(query), :hl => "en")
  end
  
  def searchUrlRestricted(query, siteDomain)
    searchUrl("site:#{siteDomain} #{query}")
  end
end

class SiteRestrictedGoogleSearcher < GoogleSearcher
  def initialize(siteDomain)
    @siteDomain = siteDomain
  end
  
  def searchUrl(query)
    queryUrl("http://www.google.com/search", :q => CGI.escape("site:" + @siteDomain + " " + query))
  end
end

$googleSearcher = GoogleSearcher.new()

class GoogleMapsSearcher
  def searchUrl(query)
    queryUrl("http://maps.google.com/maps", :q => CGI.escape(query))
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
    @searcher = SiteRestrictedGoogleSearcher.new(@domain)
  end
  
  def searchUrl(query)
    @searcher.searchUrl(query)
  end

end

class WellingtonRVSite
  
  @@addressRegex = /^([^\d]*(\d+))([^\d]+(\d+)|)[^\d\s]*\s+([^\s]+)/
  
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def searchUrl(query)
    addressMatch = @@addressRegex.match(query)
    #puts "query = #{query.inspect}, addressMatch = #{addressMatch.inspect}"
    if addressMatch
      streetNumber = if addressMatch[4] then addressMatch[4] else addressMatch[2] end
      name = addressMatch[5]
      "http://www.wellington.govt.nz/services/rates/search/results.php" + 
        "?type=address&streetStartNumber=#{streetNumber}&streetName=#{name}"
    else
      "http://www.wellington.govt.nz/services/rates/search/search.html"
    end
  end
end

def getStreetNumberAndName(address)
  addressRegex = /^([^\d]*(\d+))([^\d]+(\d+)|)[^\d\s]*\s+([^\s]+)/
  addressMatch = addressRegex.match(address)
  if addressMatch
    number = if addressMatch[4] then addressMatch[4] else addressMatch[2] end
    name = addressMatch[5]
    return {:number => number, :name => name}
  else
    return nil
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
  haml :index
end

get '/wellingtonRvPreSearch' do
  @address = reduced(params[:address])
  @streetNumberAndName = getStreetNumberAndName(@address)
  if @streetNumberAndName
    @streetNumber = @streetNumberAndName[:number]
    @streetName = @streetNumberAndName[:name]
  end
  haml :wellingtonRvPreSearch
end
