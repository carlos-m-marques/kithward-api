class KwAttributeSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name

  association :kw_values, name: :values, blueprint: KwValueSerializer
end
