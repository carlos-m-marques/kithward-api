# run in rails console with
# require 'data_processing/community_grouper'; CommunityGrouper.process
#

module CommunityGrouper
  def self.process

    candidates = Community.connection.select_all("SELECT name, city, state, COUNT(*) AS cnt FROM communities GROUP BY name, city, state HAVING COUNT(*) > 1")

    for candidate in candidates
      if candidate['name'].blank?
        STDERR.puts "Blank name!!!"
        next
      end


      same_name = Community.where("status = 'A' AND name = ? AND city = ? AND state = ?", candidate['name'], candidate['city'], candidate['state']).to_a
      if same_name.group_by(&:care_type).select {|k, v| v.length > 1}.any?
        STDERR.puts "Multiple facilities of the same type for '#{candidate['name']}'"
        next
      end

      STDERR.puts "Matching #{same_name.length} entries for '#{candidate['name']}'"
      ids = same_name.collect(&:id)
      same_name.each do |community|
        community.data['related_communities'] = ids.select {|id| id != community.id}.join(", ")
        community.save
      end
    end
  end
end
