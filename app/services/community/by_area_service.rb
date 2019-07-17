class Community::ByAreaService
  RESULT = Struct.new(:valid?, :error, :values)

  def self.search(type:, value:, params: {})
    search_options = {
      load: false,
      limit: 100
    }
    search_options.merge!(optional_search(params))
    response = build_response Community.search('*', search_options.deep_symbolize_keys)
    RESULT.new(true, nil, response)
  end

  private

  def self.error(msg)
    RESULT.new(false, msg)
  end

  def self.optional_search(params)
    {}.tap do |options|
      options[:limit] = params[:limit] if params[:limit]
      options[:page] = params[:page] if params[:page]
      options[:order] = { _score: :desc }
      options[:order].merge!(sort_order(params[:order])) if params[:order]
      options[:order].merge!({_id: :desc})
      options[:where] = sanitized_where_params(params)
    end
  end

  def self.sort_order(params_order)
    orders = params_order.to_s.split(',')
    {}.tap do |orders_hash| 
      orders.each do |order|
        field, direction = order.split(':')
        orders_hash[field.to_sym] = direction ? direction.to_sym : :desc
      end
    end
  end

  def self.sanitized_where_params(params)
    options = {}
    return options if !params[:where]
    where_params = params[:where].to_unsafe_h
    options.merge! set_price_range(where_params.delete(:lower_rent_bound), where_params.delete(:upper_rent_bound))
    options[:care_type] = set_care_type(where_params.delete(:care_type)) if where_params[:care_type]
    options.merge! where_params
    options
  end

  def self.set_care_type(care_type)
    case care_type.downcase
    when 'i', 'independent'
      Community::TYPE_INDEPENDENT
    when 'a', 'assisted'
      Community::TYPE_ASSISTED
    when 'n', 'nursing'
      Community::TYPE_NURSING
    when 'm', 'memory'
      Community::TYPE_MEMORY
    end
  end

  def self.set_price_range(lower_rent_bound, upper_rent_bound)
    {}.tap do |options|
      if (lower_rent_bound.present? && upper_rent_bound.present?) 
        options[:_or] = [
          {
            monthly_rent_lower_bound: {
              gt: lower_rent_bound.to_i,
              lt: upper_rent_bound.to_i
            } 
          },
          {
            monthly_rent_upper_bound: {
              gt: lower_rent_bound.to_i,
              lt: upper_rent_bound.to_i
            }
          }
        ]
      end
    end
  end

  def self.build_response(community_result)
    {
      total: community_result.response.dig('hits', 'total'),
      page: community_result.options.dig(:page),
      per_page: community_result.options.dig(:per_page),
      results: community_result.results
    }
  end

end