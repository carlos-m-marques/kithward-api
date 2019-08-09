class LeadSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name, :phone, :email, :account_id, :community_id, :request, :message, :created_at, :updated_at
end
