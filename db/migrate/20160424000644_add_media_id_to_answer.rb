class AddMediaIdToAnswer < ActiveRecord::Migration
  def change
    add_column :medias, :reference_type, :string
  end
end
