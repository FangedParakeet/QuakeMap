require 'open-uri'
require 'json'

module ApplicationHelper
  
  def find_quakes north, south, east, west, maxRows # Returns earthquakes from api given boundaries and optional date
      quakes = JSON.parse(open("http://api.geonames.org/earthquakesJSON?north=#{north.to_s}&south=#{south.to_s}&east=#{east.to_s}&west=#{west.to_s}&maxRows=#{maxRows}&username=FangedParakeet").read)
    return quakes["earthquakes"]
  end
  
  def locate_bounds locality # Returns coordinate boundaries for a given location from Google Maps api
    while locality.sub(" ", "+") != locality # Remove white space
      locality.sub!(" ", "+")
    end
    location = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?address=#{locality}&sensor=false").read)
    if location["status"] == "OK"
      if location["results"].first["types"].include?("street_address") || location["results"].first["types"].include?("point_of_interest") # Expand bounds if street address given
        place = String.new
        location["results"].first["address_components"].each do |component|
          if component["types"].include?("locality")
            place = component["short_name"]
          end
        end
        return locate_bounds place
      else
        if location["results"].first["geometry"]["bounds"]
          return location["results"].first["geometry"]["bounds"]
        else
          return location["results"].first["geometry"]["viewport"]
        end
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
      return nil
    end
  end
  
  def real_name locality # Given a user entry, will translate to full, formatted location name by Google Maps api
    while locality.sub(" ", "+") != locality # Remove white space
      locality.sub!(" ", "+")
    end
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
      this_quake = Quake.find_by_eqid(earthquake["eqid"])
      if top_ten.nil?
        if this_quake
          quakes << this_quake
        else
            quakes << Quake.create(eqid: earthquake["eqid"], 
              magnitude: earthquake["magnitude"], 
              longitude: earthquake["lng"], 
              latitude: earthquake["lat"], 
              date: earthquake["datetime"],
              location: locate_name(earthquake["lat"], earthquake["lng"]))
        end
      else
        if this_quake
          this_quake.top = top_ten
          this_quake.save
          quakes << this_quake
        else
          quakes << Quake.create(eqid: earthquake["eqid"], 
            magnitude: earthquake["magnitude"], 
            longitude: earthquake["lng"], 
            latitude: earthquake["lat"], 
            date: earthquake["datetime"],
            location: locate_name(earthquake["lat"], earthquake["lng"]),
            top: top_ten)
        end
      end
    end
    return quakes
  end
  
  def store_top_ten date, range
    quakes = []
    earthquakes = find_quakes 90, -90, 180, -180, range
    earthquakes.each do |earthquake|
      if quakes.length < 10
        if DateTime.strptime(earthquake["datetime"], '%Y-%m-%d %H:%M:%S') > date
          this_quake = Quake.find_by_eqid(earthquake["eqid"])
          if this_quake
            this_quake.top = true
            this_quake.save
            quakes << this_quake
          else
            quakes << Quake.create(eqid: earthquake["eqid"], 
              magnitude: earthquake["magnitude"], 
              longitude: earthquake["lng"], 
              latitude: earthquake["lat"], 
              date: earthquake["datetime"],
              location: locate_name(earthquake["lat"], earthquake["lng"]),
              top: true)
          end
        end
      end
    end
    if quakes.length < 10
      return store_top_ten date, (range+20)
    else
      return quakes        
    end
  end
      
end
