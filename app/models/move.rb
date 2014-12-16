class Move < ActiveRecord::Base
  belongs_to :user
  belongs_to :match
  validates :match_id, presence: :true
  validates :user_id, presence: :true
  validates :square, uniqueness: {scope: :match_id}
  validates :square, numericality: { only_integer: true, less_than_or_equal_to: 9, greater_than: 0 }
  validate :no_winner, on: :create
  validate :user_must_be_playing, on: :create
  validate :must_be_users_turn, on: :create
  validate :square_must_be_free, on: :create

  def no_winner
    if match.winner_id?
      errors.add(:match, "match already won.")
    end
  end

  def user_must_be_playing
    unless user_id == match.player_x_id || user_id == match.player_o_id
      errors.add(:user_id, "this user is not playing.")
    end
  end

  def must_be_users_turn
    unless all_moves_in_this_moves_match.empty? ||  last_player != user_id
      errors.add(:user_id, "it's not this player's turn.")
    end
  end  

  def last_player
    all_moves_in_this_moves_match.last.user_id
  end

  def all_moves_in_this_moves_match
    self.match.moves
  end

  def square_must_be_free
    unless all_moves_in_this_moves_match.where(square: self.square).empty?
      errors.add(:square, "this square is taken.")
    end
  end

end
