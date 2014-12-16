class ChangeColumnNames < ActiveRecord::Migration
  def change
    rename_column :matches, :player_x, :player_x_id
    rename_column :matches, :player_o, :player_o_id
  end
end
