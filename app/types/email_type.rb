class EmailType < ActiveRecord::Type::String
  def cast(value)
    super(value.downcase)
  end

  def serialize(value)
    value.downcase
  end
end
