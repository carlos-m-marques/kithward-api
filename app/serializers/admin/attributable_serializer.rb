module Admin
  class AttributableSerializer < Blueprinter::Base
    identifier :id

    field :name

    association :kw_values, blueprint: Admin::KwValueSerializer
  end
end
