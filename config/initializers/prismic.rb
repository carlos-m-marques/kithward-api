if Rails.env.production?
  require 'prismic'

  $PRISMIC_BASE_URI = 'https://kithward.prismic.io/api'  # Ruby library doesn't like /v2
else
  $PRISMIC_BASE_URI = false
end
