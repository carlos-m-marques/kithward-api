require 'sendgrid-ruby'

module MailTools
  def self.send_template(to, template, params)
    if Rails.env.test?
      raise "Tests should mock any calls to MailTools.send_template"
    end

    mail = SendGrid::Mail.new
    mail.from = SendGrid::Email.new(email: 'help@kithward.com', name: "Kithward")

    personalization = SendGrid::Personalization.new

    if !Rails.env.production? || ENV['REROUTE_EMAIL']
      personalization.add_to(SendGrid::Email.new(email: ENV['REROUTE_EMAIL'] || 'sd@kithward.com', name: "Originally for #{to}"))
    else
      personalization.add_to(SendGrid::Email.new(email: to))
    end

    personalization.add_dynamic_template_data(params)

    mail.add_personalization(personalization)
    mail.template_id = template

    sg = SendGrid::API.new(api_key: Rails.application.credentials.dig(:sendgrid, :api_key))
    sg.client.mail._("send").post(request_body: mail.to_json)
  end
end
