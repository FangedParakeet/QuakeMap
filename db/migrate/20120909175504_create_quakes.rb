class CreateQuakes < ActiveRecord::Migration
  def change
    create_table :quakes do |t|
      t.string :eqid
      t.float :magnitude
      t.float :longitude
      t.float :latitude
      t.boolean :gmaps
      t.datetime :date

      t.timestamps
    end
  end
end
