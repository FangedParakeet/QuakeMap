class AddTopToQuake < ActiveRecord::Migration
  def change
    add_column :quakes, :top, :bool
  end
end
