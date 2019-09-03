module Admin
  class KwClassSerializer < Blueprinter::Base
    identifier :id

    fields :name, :created_at, :updated_at

    association :kw_attributes, name: :attributes, blueprint: Admin::KwAttributeSerializer do |klass, opts|
      if opts[:hidden]
        klass.kw_attributes.hidden
      elsif opts[:visible]
        klass.kw_attributes.visible
      else
        klass.kw_attributes
      end
    end
  end
end
