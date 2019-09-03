class AccountAccessRequestSerializer < Blueprinter::Base
  identifier :id

  fields :first_name, :last_name, :title, :phone_number, :company_name, :company_type, :reason, :work_email, :state

  view 'complete' do
    association :account, blueprint: AccountSerializer
    association :communities, blueprint: CommunitySerializer, view: 'simple'
  end
end
