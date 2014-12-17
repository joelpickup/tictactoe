class MovesController < ApplicationController

  def create
    square = params[:square].first.first.to_i
    match_id = params[:match_id].first.first.to_i
    @move = Move.new(square: square, user: current_user, match_id: match_id)
    redirect_to @match
  end

  def move_params
    params.require(:move).permit(:square, :match_id, :user_id)
  end
end
