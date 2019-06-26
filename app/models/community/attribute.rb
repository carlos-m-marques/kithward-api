class Community::Attribute < ApplicationRecord
  include Community::Base

  enum data_type: { option: 0 }, _prefix: :data_type

  belongs_to :community_class
  validates_presence_of :name, :priority, :is_required, :data_type
end
