include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :top_ten
  
  def top_ten # Top ten earthquakes within last 12 months
    @top_ten = store_top_ten 1.year.ago, 20
  end
  
end
