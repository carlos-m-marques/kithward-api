# == Schema Information
#
# Table name: kw_super_classes
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type       :string
#  care_type  :string
#
# Indexes
#
#  index_kw_super_classes_on_care_type  (care_type)
#  index_kw_super_classes_on_type       (type)
#

class UnitSuperClass < KwSuperClass
end
