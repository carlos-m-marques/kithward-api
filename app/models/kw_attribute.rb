# == Schema Information
#
# Table name: kw_attributes
#
#  id              :bigint(8)        not null, primary key
#  kw_class_id     :bigint(8)
#  name            :string           not null
#  is_care_type_il :boolean          default(FALSE), not null
#  is_care_type_sn :boolean          default(FALSE), not null
#  is_care_type_mc :boolean          default(FALSE), not null
#  is_care_type_al :boolean          default(FALSE), not null
#  is_owner        :boolean          default(FALSE), not null
#  is_community    :boolean          default(FALSE), not null
#  is_building     :boolean          default(FALSE), not null
#  is_unit         :boolean          default(FALSE), not null
#  is_unit_type    :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_kw_attributes_on_kw_class_id  (kw_class_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_class_id => kw_classes.id)
#

class KwAttribute < ApplicationRecord
  belongs_to :kw_class
  has_many :kw_values
end
