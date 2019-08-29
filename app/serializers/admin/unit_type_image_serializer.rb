module Admin
  class UnitTypeImageSerializer < Blueprinter::Base
    identifier :id

    fields :caption, :tags, :sort_order, :content_type, :file_url, :content_type, :published

    view 'list' do
    end

    view 'complete' do
      include_view 'list'
    end
  end
end
