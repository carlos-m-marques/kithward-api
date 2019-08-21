module Admin
  class CommunityImageSerializer < Blueprinter::Base
    include Rails.application.routes.url_helpers

    identifier :id

    view 'list' do
      fields :caption, :tags, :sort_order, :content_type, :file_url
    end

    view 'complete' do
      include_view 'list'
    end
  end
end
