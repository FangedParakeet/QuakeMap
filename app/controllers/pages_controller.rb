class PagesController < ApplicationController
  
  def home
    if @top_ten
      @markers = @top_ten.to_gmaps4rails
    else
      @markers = Quake.all.to_gmaps4rails
    end
  end
    
  def show
    @location = real_name(params[:location]) # Translates user entry to more legible place name
    bounds = locate_bounds(params[:location]) # Creates boundaries for earthquake search
    search = find_quakes(bounds["northeast"]["lat"], bounds["southwest"]["lat"], bounds["northeast"]["lng"], bounds["southwest"]["lng"], nil) # Finds earthquakes within bounds
    @quakes = store_quakes(search)
    if @quakes.empty?
      if @top_ten
        @markers = @top_ten.to_gmaps4rails
      else
        @markers = Quake.all.to_gmaps4rails
      end
    else
      @markers = @quakes.to_gmaps4rails
    end
  end
  
end