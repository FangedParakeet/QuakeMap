require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '1h' do
  
  Quake.find_all_by_top(true).each do |quake|
    quake.top = false
  end # Reset top_ten
  
  top = find_quakes(90, -90, 180, -180, 1.year.ago.strftime("%Y-%m-%d"))
  store_quakes(top, true) # Update top_ten
  
end