require 'mail_tools'

class ShareMailerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(params)
    params = JSON.parse(params).transform_keys(&:to_sym)
    # origin: 'Kithward', message: '', t_args: ''
    # ap params

    return unless params[:community_name] && params[:to]

    _, to,  origin, message, t_args, community_name = params.values

    host = ENV['FRONTEND_URL'] || 'https://kithward-web-staging.herokuapp.com'

    tracking = {}

    if t_args.split(',').count > 1
      t_args.split(',').map do |arg|
        arg.strip!

        if arg.split('=').count > 1
          tracking[arg.split('=')[0].strip] = arg.split('=')[1].strip
        elsif arg.split(':').count > 1
          tracking[arg.split(':')[0].strip] = arg.split(':')[1].strip
        else
          if tracking[:tracking].present?
            tracking[:tracking] << arg
          else
            tracking[:tracking] = [arg]
          end
        end
      end

      tracking[:tracking] = tracking[:tracking].join(' ') if tracking[:tracking]
    else
      tracking[:tracking] = t_args.strip!
    end

    url = "#{host}?#{URI.encode_www_form(tracking)}"

    mailer_params = {
      shared_by: origin,
      community_name: community_name,
      message: message,
      share_link: url
    }

    MailTools.send_template(to, 'd-426db5efcc5144feafee64d8a0f5c417', mailer_params)
  end
end
