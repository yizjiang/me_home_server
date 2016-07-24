class AddLicenseIdToBrokerCompany < ActiveRecord::Migration
  def change
    add_column :broker_companies, :license_id, :string
  end
end
