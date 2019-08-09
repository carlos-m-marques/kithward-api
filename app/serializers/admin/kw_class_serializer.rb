module Admin
  class KwClassSerializer < Blueprinter::Base
    identifier :id

    fields :name

    association :kw_attributes, name: :attributes, blueprint: Admin::KwAttributeSerializer
  end
end
