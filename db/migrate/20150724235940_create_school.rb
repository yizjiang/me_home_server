class CreateSchool < ActiveRecord::Migration
def change
    create_table :schools do |t|
      t.string :name
      t.string :grade
      t.float :student_teacher_ratio
      t.float :rating
      t.string :school_type
    end
  end
end
