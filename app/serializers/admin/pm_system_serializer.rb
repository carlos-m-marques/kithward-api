module Admin
  class PmSystemSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields(:name)
    end

    view 'complete' do
      include_view 'list'

      association :owners, blueprint: Admin::OwnerSerializer, view: 'list'
    end
  end
end
