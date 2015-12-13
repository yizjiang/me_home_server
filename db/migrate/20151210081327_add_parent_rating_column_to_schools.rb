class AddParentRatingColumnToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :parent_rating, :float
  end
end
