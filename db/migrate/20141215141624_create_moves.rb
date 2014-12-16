class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :match_id
      t.integer :user_id
      t.integer :square
      t.string :value

      t.timestamps
    end
  end
end
