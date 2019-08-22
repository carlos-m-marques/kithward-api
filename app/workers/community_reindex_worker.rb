class CommunityReindexWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'searchkick'

  def perform(community_id)
    community = Community.find(id)
    community.reindex
  end
end
