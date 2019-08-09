FactoryBot.define do
  sequence :account_name do |n|
    "Account \##{n}"
  end

  sequence :account_email do |n|
    "account-#{n}@example.com"
  end

  factory :account do
    email { generate :account_email }
    verified_email { email }
    name { generate :account_name }
    password { "123" }
    status { Account::STATUS_REAL }
  end
end
