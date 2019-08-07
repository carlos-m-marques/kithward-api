class KwSuperClassSerializer < Blueprinter::Base
  fields :name

  association :kw_classes, name: :classes, blueprint: KwClassSerializer
end
