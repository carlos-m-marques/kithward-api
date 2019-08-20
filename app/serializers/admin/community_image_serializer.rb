module Admin
  class CommunityImageSerializer < Blueprinter::Base
    include Rails.application.routes.url_helpers

    identifier :id

    view 'list' do
      fields :caption, :tags, :sort_order, :content_type
    end

    view 'complete' do
      include_view 'list'

      field :file_url do |record, options|
        options[:file_url]
      end
    end
  end
end
