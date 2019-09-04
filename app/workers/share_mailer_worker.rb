require 'mail_tools'

class ShareMailerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(target, community_name, t_args)
    host = ENV['FRONTEND_URL'] || 'https://kithward-web-staging.herokuapp.com'
    url = "#{host}?#{URI.encode_www_form(tracking: t_args)}"

    mailer_params = {
      shared_by: 'Kithward',
      community_name: community_name,
      share_link: url
    }

    MailTools.send_template(target, 'd-426db5efcc5144feafee64d8a0f5c417', mailer_params)
  end
end
