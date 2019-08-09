module Admin
  class KwAttributeSerializer < Blueprinter::Base
    identifier :id

    fields :name

    association :kw_values, name: :values, blueprint: Admin::KwValueSerializer
  end
end
