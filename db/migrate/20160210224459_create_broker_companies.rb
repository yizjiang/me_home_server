class CreateBrokerCompanies < ActiveRecord::Migration
  def change
    create_table :broker_companies do |t|
      t.string :name
      t.string :addr
      t.string :city
      t.string :state
      t.integer :zipcode
      t.string :country
      t.string :phone

      t.timestamps
    end
  end
end
