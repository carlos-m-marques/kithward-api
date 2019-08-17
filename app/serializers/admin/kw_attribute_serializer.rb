module Admin
  class KwAttributeSerializer < Blueprinter::Base
    identifier :id

    fields :name, :ui_type, :created_at, :updated_at

    association :kw_values, name: :values, blueprint: Admin::KwValueSerializer
  end
end
