class AddDescriptionToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :description, :text
  end
end
