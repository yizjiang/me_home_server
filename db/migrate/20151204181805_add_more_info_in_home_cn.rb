class AddMoreInfoInHomeCn < ActiveRecord::Migration
  def change
    unless column_exists? :homes_cn, :indoor_size
      add_column :homes_cn, :indoor_size, :string
    end
    unless column_exists? :homes_cn, :lot_size
      add_column :homes_cn, :lot_size, :string
    end
    unless column_exists? :homes_cn, :price
      add_column :homes_cn, :price, :string
    end
    unless column_exists? :homes_cn, :unit_price
      add_column :homes_cn, :unit_price, :string
    end
    unless column_exists? :homes_cn, :home_type
      add_column :homes_cn, :home_type, :string
    end
  end
end
