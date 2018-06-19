# == Schema Information
#
# Table name: keyword_groups
#
#  id         :bigint(8)        not null, primary key
#  name       :string(64)
#  label      :string(128)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_keyword_groups_on_label  (label)
#  index_keyword_groups_on_name   (name)
#

class KeywordGroup < ApplicationRecord
  has_many :keywords
end
