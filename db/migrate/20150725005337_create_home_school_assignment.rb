class CreateHomeSchoolAssignment < ActiveRecord::Migration
def change
    create_table :home_school_assignments do |t|
      t.integer :home_id
      t.integer :school_id
      t.float :distance
      t.boolean :assigned
    end
  end
end
