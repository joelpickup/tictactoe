class MatchesController < ApplicationController

  def new
    @users = User.all - [current_user, User.find(3)]
    @match = Match.new
  end

  def create
    @users = User.all - [current_user, User.find(3)]
    @match = Match.challenge(match_params.merge({challenger_id: current_user.id}))
    @match.save
    redirect_to(@match)
  end

  def show
    @match = Match.find(params[:id])
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
