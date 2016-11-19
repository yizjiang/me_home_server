class CreateMetricHomeTrackings < ActiveRecord::Migration
  def up
    create_table :metric_home_trackings do |t|
      t.integer :uid
      t.integer :hid
      t.string :source
      t.string :status
      t.integer :viewed_time
      t.timestamps
    end
    add_index :metric_home_trackings, :uid
    add_index :metric_home_trackings, :hid
    add_index :metric_home_trackings, :source
    add_index :metric_home_trackings, :status
    add_index :metric_home_trackings, :viewed_time
  end

  def down
    drop_table :metric_home_trackings
  end
end
