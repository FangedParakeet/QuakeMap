class Quake < ActiveRecord::Base
  attr_accessible :date, :eqid, :gmaps, :latitude, :longitude, :magnitude, :location
  
  acts_as_gmappable
  
  def gmaps4rails_address
    "#{self.latitude}, #{self.longitude}"
  end
  
  def gmaps4rails_infowindow
    if self.location == "ZERO_RESULTS"
      "Date: #{self.date}, Magnitude: #{self.magnitude}"
    else
      "#{self.location}, Date: #{self.date.strftime("%e %b %Y")}, Magnitude: #{self.magnitude}"
    end
  end
  
  def gmaps4rails_title
    
  end
end
