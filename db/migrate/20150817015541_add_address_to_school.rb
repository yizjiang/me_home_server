class AddAddressToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :address_id, :integer
  end
end
