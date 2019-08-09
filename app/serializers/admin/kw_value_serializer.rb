module Admin
  class KwValueSerializer < Blueprinter::Base
    identifier :id

    fields :name
  end
end
