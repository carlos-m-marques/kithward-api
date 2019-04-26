# == Schema Information
#
# Table name: poi_categories
#
#  id   :bigint(8)        not null, primary key
#  name :string(128)
#

class PoiCategorySerializer < Blueprinter::Base
  identifier :idstr, name: :id

  field :name
end
