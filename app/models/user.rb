class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :rememberable, :trackable, :validatable

  has_many :moves
  has_many :matches_as_x, class_name: 'Match',foreign_key: :player_x_id
  has_many :matches_as_o, class_name: 'Match', foreign_key: :player_o_id


def wins
  matches_as_x.where(winner_id: id) + matches_as_o.where(winner_id: id)
end

def wincount
  wins.count
end


end
