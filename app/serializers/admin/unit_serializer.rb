module Admin
  class UnitSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields(
        :name,
        :unit_type_id,
        :building_id,
        :is_available,
        :date_available,
        :rent_market,
        :unit_number
      )
    end

    view 'complete' do
      include_view 'list'

      association :kw_values, blueprint: Admin::KwValueSerializer
    end
  end
end
