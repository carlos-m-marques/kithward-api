class CopyProdDbToStagingService
  class << self
    def run
      return false unless db_copy
      return false unless run_rails_dbmigrate
      run_rake_tasks
    end

    private

    def db_copy
      system("heroku run 'heroku pg:copy kwapi::DATABASE_URL DATABASE_URL -a kithward-api-staging --confirm kithward-api-staging' -a kithward-api-staging")
    end

    def run_rails_dbmigrate
      system("heroku run 'rails db:migrate' -a kithward-api-staging")
    end

    def run_rake_tasks
      # First one only needed while the rent data doesn't come from unit table. Remove after the refactor
      system("heroku run 'rake add_data_to_communities_with_rent_data' -a kithward-api-staging") &&
      system("heroku run rails runner 'Community.reindex; GeoPlace.reindex; Poi.reindex' -a kithward-api-staging")
    end
  end
end