class PoiCategorySerializer < Blueprinter::Base
  identifier :idstr, name: :id

  field :name
end
