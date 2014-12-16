class Match < ActiveRecord::Base
  has_many :moves
  belongs_to :player_x, class_name: 'User'
  belongs_to :player_o, class_name: 'User'
  validates :player_x_id, presence: :true
  validates :player_o_id, presence: :true

  @winning_combos = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

  def self.new_match(player_x,player_o)
    Match.create(player_x_id: player_x, player_o_id: player_o)
  end

  def add_move(user_id,square)
    if winner_id != nil
      puts "This match has already been won."
    else
      if !is_user_playing?(user_id)
        puts "That user isn't playing in this match."
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
  end


  def is_my_turn?(player)
    is_user_playing?(player) && (moves.empty? || saved_moves.last.user_id != player)
  end

  def has_player_x_won?
    player_moves = moves.where(user_id: player_x_id)
    player_squares = player_moves.map {|move| move.square }
    win_test = @winning_combos.map {|combo| (combo - player_squares).empty?}
    if win_test.include?(true)
      return true 
    else
      return false
    end
  end

  def has_player_o_won?
    player_moves = moves.where(user_id: player_o_id)
    player_squares = player_moves.map {|move| move.square }
    win_test = @winning_combos.map {|combo| (combo - player_squares).empty?}
    if win_test.include?(true)
      return true 
    else
      return false
    end
  end

  def is_there_a_winner?
    has_player_x_won? || has_player_o_won?
  end

  def winner
    if has_player_x_won?
      return player_x_id
    elsif has_player_o_won?
      return player_o_id
    end
  end

  def players
    [player_x, player_o]
  end

  def is_user_playing?(player)
    player_x_id == player || player_o_id == player
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

end
