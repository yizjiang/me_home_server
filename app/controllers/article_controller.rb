class ArticleController < ApplicationController
  def index
  end

  def show
    render json: Article.find(params[:id])
  end
end