class UpdateCareTypes < ActiveRecord::Migration[5.2]
  TYPE_UNKNOWN = '?'
  TYPE_INDEPENDENT = 'I'

  def change
    Community.where(care_type: TYPE_UNKNOWN).update_all(care_type: TYPE_INDEPENDENT)
  end
end
