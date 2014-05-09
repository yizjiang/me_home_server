class PostCardsController < ApplicationController
  # GET /post_cards
  # GET /post_cards.json
  before_filter :authenticate_user!
  def index
    @post_cards = current_user.post_cards

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.json { render json: @post_cards }
    #end
  end

  # GET /post_cards/1
  # GET /post_cards/1.json
  def show
    @post_card = PostCard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post_card }
    end
  end

  # GET /post_cards/new
  # GET /post_cards/new.json
  def new
    @post_card = current_user.post_cards.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post_card }
    end
  end

  # GET /post_cards/1/edit
  def edit
    @post_card = PostCard.find(params[:id])
  end

  # POST /post_cards
  # POST /post_cards.json
  def create
    @post_card = current_user.post_cards.new(params[:post_card])

    respond_to do |format|
      if @post_card.save
        format.html { redirect_to @post_card, notice: 'Post card was successfully created.' }
        format.json { render json: @post_card, status: :created, location: @post_card }
      else
        format.html { render action: "new" }
        format.json { render json: @post_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /post_cards/1
  # PUT /post_cards/1.json
  def update
    @post_card = PostCard.find(params[:id])

    respond_to do |format|
      if @post_card.update_attributes(params[:post_card])
        format.html { redirect_to @post_card, notice: 'Post card was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post_cards/1
  # DELETE /post_cards/1.json
  def destroy
    @post_card = PostCard.find(params[:id])
    @post_card.destroy

    respond_to do |format|
      format.html { redirect_to post_cards_url }
      format.json { head :no_content }
    end
  end
end
