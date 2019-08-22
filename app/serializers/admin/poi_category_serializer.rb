module Admin
  class PoiCategorySerializer < Blueprinter::Base
    identifier :id

    field :name
  end
end
