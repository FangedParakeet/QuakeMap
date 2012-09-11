include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :top_ten
  
  def top_ten # Top ten earthquakes within last 12 months
    if Quake.find_all_by_top(true).empty? # Should only run the first time website is loaded. Top ten earthquakes within 12 months updated hourly by Rufus Scheduler to minimise api requests.
      top = find_quakes(90, -90, 180, -180, 1.year.ago.strftime("%Y-%m-%d"))
      if !top.nil?
        @top_ten = store_quakes(top, true)
      else
        @top_ten = nil
      end
    else
      @top_ten = Quake.find_all_by_top(true)
    end
    return @top_ten
  end
  
end
