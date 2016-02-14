class AddMoreColumnsToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :addr1, :string
    add_column :schools, :addr2, :string
    add_column :schools, :city, :string
    add_column :schools, :county, :string
    add_column :schools, :state, :string
    add_column :schools, :zipcode, :integer
    add_column :schools, :phone, :string
    add_column :schools, :url, :string
    add_column :schools, :mail, :string
    add_column :schools, :rank, :integer
    add_column :schools, :founded, :string
    add_column :schools, :gender_type, :string
    add_column :schools, :female_pct, :float
    add_column :schools, :religion, :string
    add_column :schools, :description, :string
    add_column :schools, :boarding_pct, :float
    add_column :schools, :admin_rate, :float
    add_column :schools, :fee, :float
    add_column :schools, :enrolled_student, :integer
    add_column :schools, :name_cn, :string
    add_column :schools, :created_at, :datetime
    add_column :schools, :updated_at, :datetime
  end
end
