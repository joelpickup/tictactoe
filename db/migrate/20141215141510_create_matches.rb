class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :player_x
      t.integer :player_o
      t.integer :winner_id

      t.timestamps
    end
  end
end
