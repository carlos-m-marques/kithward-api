class BuildingSerializer < Blueprinter::Base
  identifier :id

  field :flagged_at
  field :flagged_for
  fields(:name, :community_id, :flagged_at, :created_at, :updated_at)

  view 'complete' do
    include_view 'list'

    association :kw_values, blueprint: Admin::KwValueSerializer
  end
end
