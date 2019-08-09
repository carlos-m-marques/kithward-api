class Lead < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :community, optional: true

  after_create :post_to_intercom

  def data
    self[:data] ||= {}
  end

  # "KW Contact Form" Intercom App
  INTERCOM_APP_TOKEN = {
    # Kithward Intercom Workspace
    'ezib7rr9' => 'dG9rOjc4NjE2NTJkX2JhNjdfNGVmZF84NmY1XzZmYjUzMGZmZjM0YToxOjA=',
    # KW Test Intercom Workspace
    'bs8ejtzq' => 'dG9rOjljM2VjZDhlXzM0ODVfNGFlYl9iMjUxXzY5MDdlOGMwYmJiNDoxOjA=',
  };



  def post_to_intercom
    return unless self.data && self.data['intercom_app_id']

    intercom = Intercom::Client.new(token: INTERCOM_APP_TOKEN[self.data['intercom_app_id']])

    message = ""
    message += "#{self.request}\n" if self.request.present?

    if self.community
      message += "for #{self.community.care_type_label} at #{self.community.name} (\##{self.community.id})"
    end

    message += "#{self.message}\n" if self.message.present?

    begin
      if account
        intercom.messages.create({
          from: {
            type: "user",
            user_id: account.id,
          },
          body: message
        })
      elsif self.email.present?
        intercom.messages.create({
          from: {
            type: "user",
            email: self.email,
          },
          body: message
        })
      elsif self.data['intercom_visitor_id']
        intercom.messages.create({
          from: {
            type: "contact",
            user_id: self.data['intercom_visitor_id']
          },
          body: message
        })
      end
    rescue Intercom::ResourceNotFound
      return false
    end
  end
end
