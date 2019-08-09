module Admin
  class KwValueSerializer < Blueprinter::Base
    identifier :id

    fields :name, :attribute_name, :attribute_id
    field :kw_class_id, name: :class_id
    field :kw_class_name, name: :class_name
    field :super_class_id
  end
end
