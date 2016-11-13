class AgentReview < ActiveRecord::Base
  attr_accessible :agent_extention_id, :comment, :expertise_rate, :knowledge_rate, :negotiation_skill_rate, :poster_id, :recommendation_rate, :responsiveness_rate, :source, :source_post_id, :source_reviewer

def self.importer(agent_review)

     agent_source_id = agent_review[0].nil? ? nil : agent_review[0].lstrip.rstrip
     reviewer = agent_review[1].nil? ? nil : agent_review[1].lstrip.rstrip
     comment = agent_review[2].nil? ? nil : agent_review[2].lstrip.rstrip
     recommendation = agent_review[3].nil? ? nil : agent_review[3].lstrip.rstrip
     knowledge = agent_review[4].nil? ? nil : agent_review[4].lstrip.rstrip
     expertise = agent_review[5].nil? ? nil : agent_review[5].lstrip.rstrip
     responsiveness = agent_review[6].nil? ? nil : agent_review[6].lstrip.rstrip
     negotiation = agent_review[7].nil? ? nil : agent_review[7].lstrip.rstrip
     source = agent_review[9].nil? ? nil : agent_review[9].lstrip.rstrip
     poster = agent_review[10].nil? ? nil : agent_review[10].lstrip.rstrip
     post_id = agent_review[11].nil? ? nil : agent_review[11].lstrip.rstrip

     if (reviewer.nil?)
       reviewer = poster
     end 

     if (source.nil?)
       source = 'wjl'
     end 
     agent = AgentExtention.where(source: 'wjl', source_id: agent_source_id).limit(1).first

     if (!(agent.nil?) && !(comment.nil?))
#       puts "agent_id=#{agent.id} reviewer=#{reviewer} poster=#{poster}, source=#{source}, post_id=#{post_id}, agent_source_id=#{agent_source_id}"
#       puts "agent_id=#{agent.id} comment=#{comment}"
       agent_review = AgentReview.where(agent_extention_id:agent.id, source_reviewer:reviewer,source:source,source_post_id:post_id, comment:comment).first_or_create
       agent_review.comment = comment
       agent_review.recommendation_rate = recommendation
       agent_review.knowledge_rate = knowledge
       agent_review.expertise_rate = expertise
       agent_review.responsiveness_rate = responsiveness
       agent_review.negotiation_skill_rate = negotiation
       agent_review.save
     end 

   end

end
