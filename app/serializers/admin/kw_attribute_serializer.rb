module Admin
  class KwAttributeSerializer < Blueprinter::Base
    identifier :id

    fields :name, :ui_type, :created_at, :updated_at, :required, :hidden
  end
end
