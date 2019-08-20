require 'mail_tools'

class VerificationMailerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(email, token, reason)
    MailTools.send_template(
      email,
      "d-eb98144a7ab2430d9cc0763d70a5e0ea",
      {
        email_address: email,
        validation_link: "#{ENV['FRONTEND_URL'] || 'https://kithward.com'}/auth/verify?#{URI.encode_www_form(email: email, verify: token, reason: reason)}"
      }
    )
  end
end
