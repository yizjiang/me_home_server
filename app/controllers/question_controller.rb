class QuestionController < ApplicationController
  def index
    uid = request.headers['HTTP_USER_ID']
    render json: Question.unanswered(uid)
  end

  def post_answer
    uid = request.headers['HTTP_USER_ID']
    question = Question.find(params[:qid])
    question.create_answer(params[:text], uid)
    render json: question   #TODO pagination
  end

end