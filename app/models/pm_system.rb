# == Schema Information
#
# Table name: pm_systems
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PmSystem < ApplicationRecord
  has_many :owners
end
