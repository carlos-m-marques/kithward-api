module Admin
  class PoiSerializer < Blueprinter::Base
    identifier :id

    fields :name,
      :street, :city, :state, :postal, :country,
      :lat, :lon

    association :poi_category, name: :category, blueprint: Admin::PoiCategorySerializer
  end
end
