class QuestionController < ApplicationController
  def index
    uid = request.headers['HTTP_UID']
    render json: Question.unanswered(uid, Time.now - 3600 * 24)
  end

  def post_answer
    uid = request.headers['HTTP_UID']
    question = Question.find(params[:qid])
    question.create_answer(params[:text], uid)
    render json: question   #TODO pagination
  end

end