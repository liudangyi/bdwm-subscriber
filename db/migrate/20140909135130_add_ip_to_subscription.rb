class AddIpToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :ip, :string
  end
end
