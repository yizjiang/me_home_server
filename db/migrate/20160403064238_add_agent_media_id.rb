class AddAgentMediaId < ActiveRecord::Migration
  def change
    add_column :medias, :receiver_media_id, :string
  end
end
