
class PoiCategoriesController < ApiController
  before_action :admin_account_required!, except: [:index, :show]

  def index
    all = PoiCategory.all

    render json: PoiCategorySerializer.render(all)
  end

  def show
    category = PoiCategory.find(params[:id])

    render json: PoiCategorySerializer.render(category)
  end

  def create
    category = PoiCategory.create(params.permit(:name))

    if category.errors.any?
      render json: { errors: category.errors}, status: :unprocessable_entity
    else
      render json: PoiCategorySerializer.render(category)
    end
  end

  def update
    category = PoiCategory.find(params[:id])
    category.update_attributes(params.permit(:name))

    if category.errors.any?
      render json: { errors: category.errors}, status: :unprocessable_entity
    else
      render json: PoiCategorySerializer.render(category)
    end
  end
end
