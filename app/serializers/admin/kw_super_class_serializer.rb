module Admin
  class KwSuperClassSerializer < Blueprinter::Base
    identifier :id

    fields :name

    association :kw_classes, name: :classes, blueprint: Admin::KwClassSerializer
  end
end
