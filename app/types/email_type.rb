class EmailType < ActiveRecord::Type::String
  def cast(value)
    return super(value) unless value.is_a?(String)
    super(value.downcase)
  end

  def serialize(value)
    return super(value) unless value.is_a?(String)
    value.downcase
  end
end
