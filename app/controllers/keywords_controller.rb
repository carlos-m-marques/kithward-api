class KeywordsController < ApplicationController
  def index
    @keywords = Keyword.all

    render json: KeywordSerializer.new(@keywords)
  end
end
