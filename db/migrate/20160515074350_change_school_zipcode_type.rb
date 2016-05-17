class ChangeSchoolZipcodeType < ActiveRecord::Migration
  def up
    change_column :schools, :zipcode, :string
  end

  def down
    change_column :schools, :zipcode, :integer
  end
end
