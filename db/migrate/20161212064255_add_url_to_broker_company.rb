class AddUrlToBrokerCompany < ActiveRecord::Migration
  def change
    add_column :broker_companies, :url, :string
  end
end
