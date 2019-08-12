module Admin
  class KwAttributeSerializer < Blueprinter::Base
    identifier :id

    fields :name, :ui_type
  
    association :kw_values, name: :values, blueprint: Admin::KwValueSerializer
  end
end
