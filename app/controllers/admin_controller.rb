class AdminController < ApplicationController
  before_action :admin_account_required!

  def clone_db
    if !Rails.env.production? && ENV['HEROKU_APP_NAME'] != CopyProdDbToStagingService::PROD_APP_NAME
      system("heroku run:detached rails runner 'CopyProdDbToStagingService.run' -a #{ENV['HEROKU_APP_NAME']}") 
      render json: { msg: "Clone production DB to #{ENV['HEROKU_APP_NAME']} environment started. This should take a few minutes." }, status: 200
    else
      render json: { msg: "Clone production DB to #{ENV['HEROKU_APP_NAME']} environment unavailable." }, status: :bad_request
    end
  end
end