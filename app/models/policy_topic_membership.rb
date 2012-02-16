class PolicyTopicMembership < ActiveRecord::Base
  belongs_to :policy
  belongs_to :policy_topic

  validates :policy, :policy_topic, presence: true

  default_scope order("policy_topic_memberships.ordering ASC")

  class << self
    def published
      joins(:policy).where("documents.state" => "published")
    end

    def for_type(type)
      joins(:policy).where("documents.type" => type)
    end
  end
end