class ChangeHomeZipcode < ActiveRecord::Migration
  def up
    change_column :homes, :zipcode, :string
  end

  def down
    change_column :homes, :zipcode, :integer
  end
end
