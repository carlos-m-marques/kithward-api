module Admin
  class BuildingSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields(:name, :community_id, :created_at, :updated_at)
    end

    view 'complete' do
      include_view 'list'

      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
