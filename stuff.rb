# ATTR_ALIASES = {
#   'type'      => 'care_type',
#   'address'   => 'street',
#   'street_address'   => 'street',
#   'zip'       => 'postal',
#   'zip_code'  => 'postal',
# }
# # keys = []
# # Community.find_each do |community|
# #   keys += community.data.keys
# # end
# # nil
# #
# #
# # keys.uniq!
#
# # Community.last(500).first
# datas = []
# super_categories = DataDictionary::Community.sections
#
# super_categories.each do |section|
#   section[:attrs].each do |k, v|
#     p v
#     # datas << v[:data]
#   end
# end
#
# datas.uniq!
#
#
#
# def check_jwt
#   require 'json_web_token'
#
#   a = JsonWebToken.encode({text: 'juststuff'}, 5.seconds.from_now)
#   b = JsonWebToken.decode(a)
#
#   puts "Info encoded with JWT an expiration of 5 seconds! token: #{a}"
#   puts "Info decoded using the generated token: #{b}"
#
#   seconds = 0
#   loop do
#     sleep 1
#     seconds += 1
#     puts "#{seconds} has passed..."
#
#     break if seconds >= 6
#   end
#
#   puts "Trying to decode with an expired token #{a}"
#   puts "Result: #{JsonWebToken.decode(a)}"
#
#   a = 'eyJhbGciOiJIUzI1NiJ9.eyJ0ZXh0IjoianVzdHN0dWZmIiwiZXhwIjoxNTY2Mjc5NzE2fQ.HNuurAgUGABnM7g133-GtEY3LcplWYCTPEKkMztdRUo'
#
#   puts "Trying to decode with an modified token #{a}"
#   puts "Result: #{JsonWebToken.decode(a)}"
#   nil
# end
#
#
# Account.create(name: 'Some Person', email: 'fa@novalid.com', password: 'password', password_confirmation: 'password')
#
