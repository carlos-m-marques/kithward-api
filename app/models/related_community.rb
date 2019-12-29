class RelatedCommunity < ActiveRecord::Base
  belongs_to :community, class_name: 'Community'
  belongs_to :related_community, class_name: 'Community'
end
