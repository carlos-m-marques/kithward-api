module Admin
  class UnitTypeImageSerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      fields :caption, :tags, :sort_order, :content_type, :file_url
    end

    view 'complete' do
      include_view 'list'
    end
  end
end
