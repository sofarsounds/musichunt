class ItemsController < ApplicationController
  before_action :require_login, only: [:new, :create, :edit, :update, :toggle]
  before_action :set_item, only: [:show]
  before_action :set_user_item, only: [:edit, :update, :toggle]

  def index
    order = params[:newest] ? {created_at: :desc} : {rank: :desc}

    @items = Item.order(order).includes(:user)
    @votes = @items.each_with_object({}) do |item, object|
      #item.votes = item.votes_for.size
      #object[item.id][:up] = item.get_upvotes.map(&:voter_id)
      #puts Array.new(item.get_upvotes.map(&:voter_id), item.get_downvotes.map(&:voter_id))
      object[item.id] = item.votes_for.map(&:voter_id)
      #object[:down] = item.get_downvotes.map(&:voter_id)
      puts "OBJ >>>> #{object}"
    end
  end

  def show
    @comments = @item.comments.includes(:user).order(created_at: :asc)
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to @item, notice: 'Item was successfully created.'
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      render :edit
    end
  end

  def toggle
    @item.update(:disabled, @item.disabled?)
    message = item.disabled? ? 'disabled' : 'enabled'
    redirect_to @item, notice: "Item #{message}."
  end

  private
  def set_item
    @item = Item.find(params[:id])
    @votes = [@item].each_with_object({}) do |item, object|
      object[item.id] = item.get_votes.map(&:voter_id)
    end
  end

  def set_user_item
    @item = current_user.items.find(params[:id])
    unless @item
      redirect_to :back, notice: 'Unauthorized'
      return
    end
  end

  def item_params
    params.require(:item).permit(:title, :url, :content)
  end
end
