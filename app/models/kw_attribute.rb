class KwAttribute < ApplicationRecord
  UI_TYPES = %w(text label select multiple-select boolean range).freeze

  belongs_to :kw_class
  has_one :kw_super_class, through: :kw_class
  has_many :kw_values, dependent: :destroy

  validates :name, :ui_type, :kw_class, presence: true
  validates :ui_type, inclusion: { in: UI_TYPES }
end
