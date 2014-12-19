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

def draws
  matches_as_x.where(winner_id: 0) + matches_as_o.where(winner_id: 0)
end

def drawcount
  draws.count
end

def losses
  m = matches_as_x.select{|match| match if match.winner_id} + matches_as_o.select{|match| match if match.winner_id}
  m.select{|m| m if m.winner_id != 0 && m.winner_id!= id}
end

def losscount
  losses.count
end

end
