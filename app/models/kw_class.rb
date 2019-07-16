# == Schema Information
#
# Table name: kw_classes
#
#  id                :bigint(8)        not null, primary key
#  name              :string           not null
#  is_care_type_il   :boolean          default(FALSE), not null
#  is_care_type_sn   :boolean          default(FALSE), not null
#  is_care_type_mc   :boolean          default(FALSE), not null
#  is_care_type_al   :boolean          default(FALSE), not null
#  is_owner          :boolean          default(FALSE), not null
#  is_community      :boolean          default(FALSE), not null
#  is_building       :boolean          default(FALSE), not null
#  is_unit           :boolean          default(FALSE), not null
#  is_unit_type      :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  kw_super_class_id :bigint(8)
#
# Indexes
#
#  index_kw_classes_on_kw_super_class_id  (kw_super_class_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_super_class_id => kw_super_classes.id)
#

class KwClass < ApplicationRecord
  has_many :kw_attributes
  belongs_to :kw_super_class
end
