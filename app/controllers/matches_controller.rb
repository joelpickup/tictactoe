class MatchesController < ApplicationController

  def new
    @users = User.all - [current_user, User.find(3)]
    @match = Match.new
  end

  def create
    @users = User.all - [current_user, User.find(3)]
    @match = Match.challenge(match_params.merge({challenger_id: current_user.id}))
   if @match.save
      redirect_to(@match)
    else
      render :new
    end
  end

  def computer
    @match = Match.new_match_vs_computer(match_params.merge({challenger_id: current_user.id}))
    if @match.save
      redirect_to(@match)
    else
      render :new
    end
  end

  def show
    @match = Match.find(params[:id])
    moves = @match.moves
    squares = moves.map {|move| move.square }
    values = moves.map {|move| move.value}
    @squares_values = Hash[squares.zip values]
    if @match.player_x_id == current_user.id
      @other_player_name = User.find(@match.player_o_id).nickname
    else
      @other_player_name = User.find(@match.player_x_id).nickname
    end
    if @match.player_x_id == current_user.id
      @playing_as = "X"
    else
      @playing_as = "O"
    end
  end

  def add_move
    square = params[:square].to_i
    @match = Match.find(params[:id])
    move = @match.add_move(current_user.id,square)
    redirect_to @match
  end

  def leaderboard
    @users = User.all - [User.find(3)]
  end


  def index
    @matches = Match.playable_matches(current_user)
    @matches.each { |match|
      if current_user == match.player_o
        match.other_player_id = match.player_x.id
      else
        match.other_player_id = match.player_o.id
      end
    }
  end

  def match_params
    params.require(:match).permit(:other_player_id, :playing_as)
  end
end
