require 'open-uri'
require 'json'

module ApplicationHelper
  
  def find_quakes north, south, east, west, date # Returns earthquakes from api given boundaries and optional date
    if date.nil?
      quakes = JSON.parse(open("http://api.geonames.org/earthquakesJSON?north=#{north.to_s}&south=#{south.to_s}&east=#{east.to_s}&west=#{west.to_s}&username=demo").read)
    else
      quakes = JSON.parse(open("http://api.geonames.org/earthquakesJSON?north=#{north.to_s}&south=#{south.to_s}&east=#{east.to_s}&west=#{west.to_s}&date=#{date}&username=demo").read)
    end
    return quakes["earthquakes"]
  end
  
  def locate_bounds locality # Returns coordinate boundaries for a given location from Google Maps api
    locality.sub!(" ", "%20")
    location = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?address=#{locality}&sensor=false").read)
    if location["status"] == "OK"
      if location["results"].first["geometry"]["bounds"]
        return location["results"].first["geometry"]["bounds"]
      else
        return location["results"].first["geometry"]["viewport"]
      end
    else
      return location["status"]
    end
  end
  
  def locate_name lat, long # Returns name of an area (if available) given a set of coordinates
    location = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{long}&sensor=false").read)
    if location["status"] == "OK"
      location["results"].each do |result|
        if result["types"].include?("political")
          return result["formatted_address"]
        end
      end
    else
      return location["status"]
    end
  end
  
  def real_name locality # Given a user entry, will translate to full, formatted location name by Google Maps api
    locality.sub!(" ", "%20")
    location = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?address=#{locality}&sensor=false").read)
    if location["status"] == "OK"
      return location["results"].first["formatted_address"]
    else
      return location["status"]
    end
  end
  
  def store_quakes earthquakes, top_ten # Receives information from earthquake api and stores it to database, so that gmaps4rails gem can create map in view
    quakes = []
    if earthquakes.nil?
      return nil
    end
    earthquakes.each do |earthquake|
      if Quake.find_by_eqid(earthquake["eqid"])
        quakes << Quake.find_by_eqid(earthquake["eqid"])
      else
        quakes << Quake.create(eqid: earthquake["eqid"], 
          magnitude: earthquake["magnitude"], 
          longitude: earthquake["lng"], 
          latitude: earthquake["lat"], 
          date: earthquake["datetime"],
          location: locate_name(earthquake["lat"], earthquake["lng"]),
          top: false)
      end
    end
    return quakes
  end
      
end
