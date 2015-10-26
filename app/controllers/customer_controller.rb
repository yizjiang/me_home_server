class CustomerController < ApplicationController
  def index
    render json: AgentRequest.all
  end

  def connect
    uid = request.headers['HTTP_USER_ID']
    aid = User.find(uid).agent_extention.agent_identifier
    request = AgentRequest.find(params[:rid])
    request.update_attributes(agent_identifier_list: aid) # TODO add to list
    request.sent_to_wechat #TODO hook method
    render json: {}
  end
end