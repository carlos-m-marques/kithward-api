require 'json_web_token'

class ApplicationController < ActionController::API
  before_action :set_raven_context
  after_action :inject_kithward_headers

  def set_raven_context # Sentry
    Raven.user_context(id: access_token_payload[:account_id])
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
  private :set_raven_context

  def inject_kithward_headers
    response.headers['X-KW'] = "#{ENV['HEROKU_APP_NAME'] || 'kwweb-development'}[#{controller_name}/#{action_name}] #{(ENV['HEROKU_SLUG_COMMIT'] || '?')[0..6]} #{ENV['HEROKU_RELEASE_CREATED_AT']}"
  end
  protected :inject_kithward_headers

  def access_token_payload
    @access_token_payload ||= begin
      access_token = nil
      if request.headers['Authorization'].present?
        access_token = request.headers['Authorization'].split(' ').last
      elsif params[:access_token]
        access_token = params[:access_token]
      end

      JsonWebToken.decode(access_token) || {}
    rescue JWT::VerificationError, JWT::DecodeError
      {}
    end
  end

  def accessing_account
    @accessing_account ||= begin
      if access_token_payload[:account_id]
        Account.find(access_token_payload[:account_id])
      end
    end
  end

  def authentication_required!
    unless accessing_account
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end

  def admin_account_required!
    unless accessing_account && accessing_account.is_admin?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end

  begin # paper trail
    before_action :set_paper_trail_whodunnit
    def user_for_paper_trail
      if accessing_account
        "#{accessing_account.id}:#{accessing_account.email}"
      else
        "anonymous"
      end
    end
  end
end
