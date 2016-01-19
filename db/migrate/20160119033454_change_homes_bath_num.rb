class ChangeHomesBathNum < ActiveRecord::Migration
  def up
    change_column :homes, :bath_num, :float 
  end

  def down
    change_column :homes, :bath_num, :int
  end

end

