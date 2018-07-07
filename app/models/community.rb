# == Schema Information
#
# Table name: communities
#
#  id             :bigint(8)        not null, primary key
#  name           :string(1024)
#  description    :text
#  is_independent :boolean          default(FALSE)
#  is_assisted    :boolean          default(FALSE)
#  is_nursing     :boolean          default(FALSE)
#  is_memory      :boolean          default(FALSE)
#  is_ccrc        :boolean          default(FALSE)
#  address        :string(1024)
#  address_more   :string(1024)
#  city           :string(256)
#  state          :string(128)
#  postal         :string(32)
#  country        :string(64)
#  lat            :float
#  lon            :float
#  website        :string(1024)
#  phone          :string(64)
#  fax            :string(64)
#  email          :string(256)
#  data           :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Community < ApplicationRecord

  searchkick  match: :word_start,
              word_start:  ['name', 'description'],
              default_fields: ['name', 'description']

  def search_data
    {
      name: name,
      description: description,
      is_independent: is_independent,
      is_assisted: is_assisted,
      is_nursing: is_nursing,
      is_memory: is_memory,
      is_ccrc: is_ccrc,
      address: address,
      address_more: address_more,
      city: city,
      state: state,
      postal: postal,
      country: country,
    }
  end
end
