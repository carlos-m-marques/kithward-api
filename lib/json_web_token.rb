class JsonWebToken
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def self.decode(token)
    body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new body
  rescue
    nil
  end

  def self.access_token_for_account(account, refresh_token = nil)
    encode(
      {
        account_id: account.id,
        account_name: account.name,
        is_admin: account.is_admin,
      },
      24.hours.from_now
    )
  end

  def self.refresh_token_for_account(account, digest)
    encode(
      {
        account_id: account.id,
        digest: digest,
      },
      2.years.from_now
    )
  end
end
