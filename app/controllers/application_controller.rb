include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :top_ten
  
  def top_ten # Top ten earthquakes within last 12 months
    top = find_quakes(90, -90, 180, -180, 1.year.ago.strftime("%Y-%m-%d"))
    if !top.nil?
      @top_ten = store_quakes(top)
    else
      @top_ten = nil
    end
    return @top_ten
  end
  
end
