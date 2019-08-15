module Admin
  class UnitTypeSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      field :flagged_at
      field :flagged_for
      fields(:name, :flagged_at, :community_id, :created_at, :updated_at)
    end

    view 'complete' do
      include_view 'list'

      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
