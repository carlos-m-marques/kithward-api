class CopyProdDbToStagingService
  class << self
    PROD_APP_NAME = 'kwapi'
    def run
      if !Rails.env.production? && ENV['HEROKU_APP_NAME'] != PROD_APP_NAME
        return false unless db_copy
        return false unless run_rails_dbmigrate
        run_rake_tasks
      end
    end

    private

    def db_copy
      system("heroku run 'heroku pg:copy #{PROD_APP_NAME}::DATABASE_URL DATABASE_URL -a #{ENV['HEROKU_APP_NAME']} --confirm #{ENV['HEROKU_APP_NAME']}' -a #{ENV['HEROKU_APP_NAME']}")
    end

    def run_rails_dbmigrate
      system("heroku run 'rails db:migrate' -a #{ENV['HEROKU_APP_NAME']}")
    end

    def run_rake_tasks
      # First one only needed while the rent data doesn't come from unit table. Remove after the refactor
      system("heroku run 'rake add_data_to_communities_with_rent_data' -a #{ENV['HEROKU_APP_NAME']}") &&
      system("heroku run rails runner 'Community.reindex; GeoPlace.reindex; Poi.reindex' -a #{ENV['HEROKU_APP_NAME']}")
    end
  end
end