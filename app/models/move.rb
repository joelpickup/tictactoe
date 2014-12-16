class Move < ActiveRecord::Base
  belongs_to :user
  belongs_to :match
  validates :match_id, presence: :true
  validates :user_id, presence: :true
  validates :square, uniqueness: {scope: :match_id}
  validates :square, numericality: { only_integer: true, less_than_or_equal_to: 9, greater_than: 0 }
  validate :no_winner, on: :create
  validate :user_must_be_playing, on: :create

  def no_winner
    if match.winner_id
      errors.add(:match, "match already won")
    end
  end

  def user_must_be_playing
    unless user_id == match.player_x_id || user_id == match.player_o_id
      errors.add(:user_id, "this user is not playing")
    end
  end

  def 

end
