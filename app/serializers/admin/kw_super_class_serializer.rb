module Admin
  class KwSuperClassSerializer < Blueprinter::Base
    identifier :id

    fields :name, :created_at, :updated_at

    association :kw_classes, name: :classes, blueprint: Admin::KwClassSerializer
  end
end
