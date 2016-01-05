class AddMeejiaTypeColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :meejia_type, :string
  end
end
