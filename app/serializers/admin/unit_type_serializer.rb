module Admin
  class UnitTypeSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields(:name, :community_id)
    end

    view 'complete' do
      include_view 'list'

      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
