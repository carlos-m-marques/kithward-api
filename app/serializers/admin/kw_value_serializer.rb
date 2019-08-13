module Admin
  class KwValueSerializer < Blueprinter::Base
    identifier :id

    fields :name, :kw_attribute_id
  end
end
