module Admin
  class PmSystemSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields(:name, :created_at, :updated_at)
    end

    view 'complete' do
      include_view 'list'

      association :owners, blueprint: Admin::OwnerSerializer, view: 'list'
      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
