class Match < ActiveRecord::Base
  has_many :moves
  belongs_to :player_x, class_name: 'User'
  belongs_to :player_o, class_name: 'User'
  validates :player_x_id, presence: :true
  validates :player_o_id, presence: :true
  validate :must_not_already_have_match, on: :create

  WINNING_COMBOS = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

  attr_accessor :challenger_id, :other_player_id, :playing_as

  def self.challenge(params)
    match = new(params)
    case params.fetch(:playing_as).to_s.downcase
    when 'o'
      match.player_o_id = params.fetch(:challenger_id)
      match.player_x_id = params.fetch(:other_player_id)
    else
      match.player_x_id = params.fetch(:challenger_id)
      match.player_o_id = params.fetch(:other_player_id)
    end
    match
  end

  def self.new_match(player_x_id,player_o_id)
    Match.create(player_x_id: player_x_id, player_o_id: player_o_id)
  end

  def add_move(user_id,square)
    value = x_or_o(user_id)
    moves.create(user_id: user_id, square: square, value: value)
    if is_there_a_winner?
      self.winner_id = self.winner
      save
    end
  end

  def is_there_a_winner?
    has_player_won?(player_x_id) || has_player_won?(player_o_id)
  end

  def has_player_won?(player_id)
    player_moves = moves.where(user_id: player_id)
    player_squares = player_moves.try(:map) {|move| move.square }
    win_test = WINNING_COMBOS.map {|combo| (combo - player_squares).empty?}
    if win_test.include?(true)
      return true 
    else
      return false
    end
  end

  def winner
    if has_player_won?(player_x_id)
      return player_x_id
    elsif has_player_won?(player_o_id)
      return player_o_id
    end
  end

  def saved_moves
    moves.collect {|move| move if move.persisted? }
  end

  def x_or_o(user_id)
    if user_id == player_o_id
      return "O"
    else 
      return "X"
    end
  end

  def self.playable_matches(current_user)
    @playable_matches = Match.where(player_x: current_user) + Match.where(player_o: current_user)
    @playable_matches.delete_if {|match| match.is_there_a_winner?}
    @playable_matches.delete_if {|match| !match.is_my_turn?(current_user)}
  end

  def is_my_turn?(current_user)
    moves.empty? || moves.last.user != current_user
  end

  def possible_moves
    all_squares = [1,2,3,4,5,6,7,8,9]
    occupied_squares = saved_moves.map {|move| move.square }
    all_squares - occupied_squares
  end

  def self.new_match_vs_computer(user_id)
    Match.create(player_x_id: user_id, player_o_id: 3)
  end

  def add_move_vs_computer(square)
    add_move(player_x_id,square)
    computer_square = possible_moves.sample
    add_move(player_o_id,computer_square)
  end

  def must_not_already_have_match
    m = Match.where(player_o_id: challenger_id, player_x_id: other_player_id, winner_id:nil) 
    n = Match.where(player_o_id: other_player_id, player_x_id: challenger_id, winner_id:nil)
    unless m.empty? && n.empty?
      errors.add(:challenger_id, "you already have a match in progress with this person!")
    end
  end
end
