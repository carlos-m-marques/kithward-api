class CommunityImageSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :caption, :tags, :sort_order, :url, :content_type
end
