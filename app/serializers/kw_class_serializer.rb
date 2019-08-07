class KwClassSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name

  association :kw_attributes, name: :attributes, blueprint: KwAttributeSerializer
end
