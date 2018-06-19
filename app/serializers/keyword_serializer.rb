# == Schema Information
#
# Table name: keywords
#
#  id               :bigint(8)        not null, primary key
#  name             :string(64)
#  label            :string(128)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  keyword_group_id :bigint(8)
#
# Indexes
#
#  index_keywords_on_keyword_group_id  (keyword_group_id)
#  index_keywords_on_label             (label)
#  index_keywords_on_name              (name)
#
# Foreign Keys
#
#  fk_rails_...  (keyword_group_id => keyword_groups.id)
#

class KeywordSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :label
  belongs_to :keyword_group
end
