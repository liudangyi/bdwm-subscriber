class CreateModels < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name
      t.string :last_id
    end
    create_table :subscriptions do |t|
      t.belongs_to :board
      t.text :keywords
      t.string :email
    end
  end
end
