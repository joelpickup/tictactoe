class Move < ActiveRecord::Base
  belongs_to :user
  belongs_to :match
  validates :match_id, presence: :true
  validates :user_id, presence: :true
  validates :square, uniqueness: {scope: :match_id}
  validates :square, numericality: { only_integer: true, less_than_or_equal_to: 9, greater_than: 0 }
end
