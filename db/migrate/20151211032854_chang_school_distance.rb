class ChangSchoolDistance  < ActiveRecord::Migration
 
  def up
    change_column :home_school_assignments, :distance, :string 
  end

  def down
    change_column :home_school_assignments, :distance, :float
  end

end
