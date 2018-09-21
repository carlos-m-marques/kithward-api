class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def idstr
    id.to_s
  end
end
