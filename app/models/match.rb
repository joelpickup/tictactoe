class Match < ActiveRecord::Base
  has_many :moves
  belongs_to :player_x, class_name: 'User'
  belongs_to :player_o, class_name: 'User'
  validates :player_x_id, presence: :true
  validates :player_o_id, presence: :true
  validate :must_not_already_have_match, on: :create

  WINNING_COMBOS  = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]
  ALL_SQUARES     = [1,2,3,4,5,6,7,8,9]

  attr_accessor :challenger_id, :other_player_id, :playing_as

  def must_not_already_have_match
    m = Match.where(player_o_id: challenger_id, player_x_id: other_player_id, winner_id:nil) 
    n = Match.where(player_o_id: other_player_id, player_x_id: challenger_id, winner_id:nil)
    unless m.empty? && n.empty?
      errors.add(:challenger_id, "you already have a match in progress with this person!")
    end
  end

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

  def check_status
    if has_player_won?(player_x_id)
      self.winner_id = player_x_id and self.save
    elsif has_player_won?(player_o_id)
      self.winner_id = player_o_id and self.save
    elsif is_draw?
      self.winner_id = 0 and self.save
    end
  end

  def computer_playing?
    player_x.role == "computer" || player_o.role == "computer"
  end

  def computer_play
    winning_move || blocking_move || computer_move
  end

  def computer_move
    moves.create!(user_id: 26, square: possible_moves.sample, value: x_or_o(26))
  end

  def winning_move
    computers_squares = moves.where(user_id: 26).map {|move| move.square}
    win_combo = WINNING_COMBOS.select { |combo| (combo - computers_squares).count == 1 }.first
    if win_combo
      win_move = win_combo - computers_squares
    else
      win_move = 0
    end
    if win_combo && possible_moves.include?(win_move)
      moves.create!(user_id: 26, square: win_move.first, value: x_or_o(26))
    else 
      return false
    end
  end

  def blocking_move
    players_squares = moves.where("User_id != 26").map {|move| move.square}
    win_combo = WINNING_COMBOS.select { |combo| (combo - players_squares).count == 1 }.first
    if win_combo
      block_move = win_combo - players_squares
    else
      win_move = 0
    end
    if win_combo && possible_moves.include?(block_move)
      moves.create!(user_id: 26, square: block_move.first, value: x_or_o(26))
    else
      return false
    end
  end

  def add_move(user_id, square)
    moves.create!(user_id: user_id, square: square, value: x_or_o(user_id))
  end

  def has_player_won?(player_id)
    player_squares = moves.map { |move| move.square if move.user_id == player_id }.compact
    WINNING_COMBOS.any? { |combo| (combo - player_squares).empty? }
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
    (user_id == player_o_id ? "O" : "X")
  end

  def is_my_turn?(current_user)
    moves.empty? || moves.last.user != current_user
  end

  def possible_moves
    ALL_SQUARES - saved_moves.map {|m| m.square }
  end

  def self.new_match_vs_computer(params)
    @computer = User.where(role:"computer").first
    match = new(params)
    case params.fetch(:playing_as).to_s.downcase
    when 'o'
      match.player_o_id = params.fetch(:challenger_id)
      match.player_x_id = @computer.id
    else
      match.player_x_id = params.fetch(:challenger_id)
      match.player_o_id = @computer.id
    end
    match
  end

  def is_draw?
    moves.count == 9 && winner_id == nil
  end

  def drawn
    winner_id == 0
  end

  def self.playable_matches(current_user)
    @playable_matches = Match.where("(player_x_id = ? OR player_o_id = ?) AND winner_id is NULL", current_user.id, current_user.id)
    @playable_matches = @playable_matches.select {|match| match.is_my_turn?(current_user)}
  end

  def self.in_progress_not_my_turn(current_user)
    @unplayable_matches = Match.where("(player_x_id = ? OR player_o_id = ?) AND winner_id is NULL", current_user.id, current_user.id)
    @unplayable_matches = @unplayable_matches.select {|match| !match.is_my_turn?(current_user)}
  end

end