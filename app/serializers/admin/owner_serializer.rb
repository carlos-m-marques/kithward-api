module Admin
  class OwnerSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields(:name, :address1, :address2, :city, :state, :zip, :pm_system_id, :created_at, :updated_at)
    end

    view 'complete' do
      include_view 'list'

      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
