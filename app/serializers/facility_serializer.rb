# == Schema Information
#
# Table name: facilities
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

class FacilitySerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :description,
    :is_independent, :is_assisted, :is_nursing, :is_memory, :is_ccrc,
    :address, :address_more, :city, :state, :postal, :country,
    :lat, :lon,
    :website, :phone, :fax, :email,
    :updated_at
end
