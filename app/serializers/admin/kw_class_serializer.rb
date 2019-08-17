module Admin
  class KwClassSerializer < Blueprinter::Base
    identifier :id

    fields :name, :created_at, :updated_at

    association :kw_attributes, name: :attributes, blueprint: Admin::KwAttributeSerializer
  end
end
