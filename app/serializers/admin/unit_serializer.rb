module Admin
  class UnitSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      field :flagged_at
      field :flagged_for
      fields(
        :name,
        :flagged_at,
        :unit_type_id,
        :building_id,
        :is_available,
        :date_available,
        :rent_market,
        :unit_number,
        :created_at,
        :updated_at
      )
    end

    view 'complete' do
      include_view 'list'

      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
