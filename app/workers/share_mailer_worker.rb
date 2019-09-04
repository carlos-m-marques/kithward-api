require 'mail_tools'

class ShareMailerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(params)
    params = JSON.parse(params).transform_keys(&:to_sym)
    # origin: 'Kithward', message: '', t_args: ''

    return unless params[:community_name] && params[:to]

    _, to,  origin, message, t_args, community_name, community_slug = params.values

    host = ENV['FRONTEND_URL'] || 'https://kithward-web-staging.herokuapp.com'

    tracking = {}

    if t_args.split(',').count > 1
      t_args.split(',').map do |arg|
        arg.strip!

        if arg.split('=').count > 1
          tracking[:tracking] = {}
          tracking[:tracking][arg.split('=')[0].strip] = arg.split('=')[1].strip
        elsif arg.split(':').count > 1
          tracking[:tracking] = {}
          tracking[:tracking][arg.split(':')[0].strip] = arg.split(':')[1].strip
        else
          if tracking[:tracking].present?
            tracking[:tracking] << arg
          else
            tracking[:tracking] = [arg]
          end
        end
      end

      if tracking[:tracking] && tracking[:tracking].is_a?(String)
        tracking[:tracking] = tracking[:tracking].join(' ')
      end
    else
      tracking[:tracking] = t_args.strip!
    end

    url = "#{host}/community/#{community_slug}?#{tracking.to_query}"

    mailer_params = {
      shared_by: origin,
      community_name: community_name,
      message: message,
      share_link: url
    }
    ap mailer_params
    puts url.green
    MailTools.send_template(to, 'd-426db5efcc5144feafee64d8a0f5c417', mailer_params)
  end
end
