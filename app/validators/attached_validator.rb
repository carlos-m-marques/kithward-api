class AttachedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :attached, { message: 'Should have attached image!' }) unless value.attached?

  end
end
