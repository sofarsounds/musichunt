class UserItemVotesController < ApplicationController
  before_action :set_item, :require_login

  def create
    if @item.votes_for.up.by_type(User).voters.collect {|x| x.id}.include?(current_user.id)
      @item.unliked_by User.find(current_user.id)
      redirect_to :back, notice: "Removed Upvote"
    else
      @item.upvote_from User.find(current_user.id)
      redirect_to :back, notice: "Upvoted"
    end
  end

  def destroy
    if @item.votes_for.down.by_type(User).voters.collect {|x| x.id}.include?(current_user.id)
      @item.undisliked_by User.find(current_user.id)
      redirect_to :back, notice: "Removed Downvote"
    else
      @item.downvote_from User.find(current_user.id)
      redirect_to :back, notice: "Downvoted"
    end
    # redirect_to :back, notice: message
  end

  private
  def set_item
    @item = Item.find(params[:id])
    unless @item
      return redirect_to :back, notice: "Could not find item with #{params[:id]}"
    end
  end

  def vote_params
    {
      votable_id: @item.id,
      votable_type: @item.class.to_s
    }
  end
end
