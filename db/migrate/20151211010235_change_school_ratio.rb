class ChangeSchoolRatio < ActiveRecord::Migration
  def up
    change_column :schools, :student_teacher_ratio, :string
  end

  def down
    change_column :schools, :student_teacher_ratio, :float
  end

end
