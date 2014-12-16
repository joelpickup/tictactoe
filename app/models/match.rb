class Match < ActiveRecord::Base
  has_many :moves
  belongs_to :player_x, class_name: 'User'
  belongs_to :player_o, class_name: 'User'
  validates :player_x_id, presence: :true
  validates :player_o_id, presence: :true


  @winning_combos = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

  def self.new_match(player_x_id,player_o_id)
    Match.create(player_x_id: player_x_id, player_o_id: player_o_id)
  end

  def add_move(user_id,square)
    elsif !is_my_turn?(user_id)
      puts "It's not your turn!"
    elsif !square_is_free?(square)
      puts "That square is taken."
    else
      value = x_or_o(user_id)
      moves.create(user_id: user_id, square: square, value: value)
      if is_there_a_winner?
        winner_id = winner
        self.save
        puts "There is a winner!"
      end
    end
  end


  def is_my_turn?(player)
    is_user_playing?(player) && (moves.empty? || saved_moves.last.user_id != player)
  end

  def has_player_won?(player_id)
    player_moves = moves.where(user_id: player_id)
    player_squares = player_moves.map {|move| move.square }
    win_test = @winning_combos.map {|combo| (combo - player_squares).empty?}
    if win_test.include?(true)
      return true 
    else
      return false
    end
  end

  def is_there_a_winner?
    has_player_won?(player_x_id) || has_player_won?(player_o_id)
  end

  def winner
    if has_player_won?(player_x_id)
      return player_x_id
    elsif has_player_won?(player_o_id)
      return player_o_id
    end
  end

  def players
    [player_x, player_o]
  end

  def square_is_free?(square)
    moves.where(square: square).empty?
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
end
