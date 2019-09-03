class AccountAccessRequestCommunity < ActiveRecord::Base
  belongs_to :account_access_request
  belongs_to :community
end
