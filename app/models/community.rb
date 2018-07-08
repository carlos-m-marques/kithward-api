# == Schema Information
#
# Table name: communities
#
#  id          :bigint(8)        not null, primary key
#  name        :string(1024)
#  description :text
#  street      :string(1024)
#  street_more :string(1024)
#  city        :string(256)
#  state       :string(128)
#  postal      :string(32)
#  country     :string(64)
#  lat         :float
#  lon         :float
#  data        :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  care_type   :string(1)        default("?")
#

class Community < ApplicationRecord
  TYPE_UNKNOWN     = '?'
  TYPE_INDEPENDENT = 'I'
  TYPE_ASSISTED    = 'A'
  TYPE_NURSING     = 'N'
  TYPE_MEMORY      = 'M'

  searchkick  match: :word_start,
              word_start:  ['name', 'description'],
              default_fields: ['name', 'description']

  def search_data
    {
      name: name,
      description: description,
      city: city,
      state: state,
      postal: postal,
      country: country,
    }
  end
end
