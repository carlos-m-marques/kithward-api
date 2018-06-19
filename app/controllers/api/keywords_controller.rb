class Api::KeywordsController < Api::ApiController
  def index
    @keywords = Keyword.all

    render json: KeywordSerializer.new(@keywords)
  end
end
