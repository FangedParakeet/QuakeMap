class AddLocationToQuake < ActiveRecord::Migration
  def change
    add_column :quakes, :location, :string
  end
end
