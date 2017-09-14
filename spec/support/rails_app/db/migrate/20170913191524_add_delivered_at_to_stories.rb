class AddDeliveredAtToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :stories, :delivered_at, :datetime
  end
end
