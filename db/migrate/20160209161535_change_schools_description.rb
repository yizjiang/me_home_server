class ChangeSchoolsDescription < ActiveRecord::Migration
  def up
    change_column :schools, :description, :text 
  end

  def down
    change_column :schools, :description, :string
  end
end
