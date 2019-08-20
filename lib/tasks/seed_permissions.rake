desc "Seed CanCanCan permissions"
task :seed_permissions => :environment do
  Permission.delete_all

  # SKIP_CONTROLLERS = %w(
  #   AuthController
  #   AdminController
  #   CommunityPoisController
  #   SitemapController
  # )
  # SKIP_ACTIONS = %w(
  #   current_account
  #   current_user
  #   authentication_required!
  #   admin_account_required!
  #   access_token_payload
  #   account_params
  # )
  #
  # write_permission("all", "manage", "Everything", "All operations", true)
  #
  # controllers = Dir.new("#{Rails.root}/app/controllers").entries
  # controllers.each do |controller|
  #   if controller =~ /_controller/
  #     foo_bar = controller.camelize.gsub(".rb","").constantize.new
  #   end
  # end
  #
  # ApiController.subclasses.each do |controller|
  #   next if SKIP_CONTROLLERS.include?(controller.name.to_s)
  #
  #   if controller.respond_to?(:permission)
  #     klass, description = controller.permission
  #     write_permission(klass, "manage", description, "All operations")
  #     controller.action_methods.each do |action|
  #       next if SKIP_ACTIONS.include?(action)
  #
  #       if action.to_s.index("_callback").nil?
  #         action_desc, cancan_action = eval_cancan_action(action)
  #         write_permission(klass, cancan_action, description, action_desc)
  #       end
  #     end
  #   end
  # end
end

def eval_cancan_action(action)
  case action.to_s
  when "index", "show", "search", "dictionary"
    cancan_action = "read"
    action_desc = I18n.t :read
  when "create", "new"
    cancan_action = "create"
    action_desc = I18n.t :create
  when "edit", "update"
    cancan_action = "update"
    action_desc = I18n.t :edit
  when "delete", "destroy"
    cancan_action = "delete"
    action_desc = I18n.t :delete
  else
    cancan_action = action.to_s
    action_desc = "Other: " << cancan_action
  end
  return action_desc, cancan_action
end

def write_permission(class_name, cancan_action, name, description, force_id_1 = false)
  class_name = class_name.name.to_s unless class_name.is_a?(String)

  # puts "class_name #{class_name.class} - cancan_action #{cancan_action.class}"
  # p '----------------------------------------------------------------------'
  # puts "Permission.where(subject_class: \"#{class_name}\", action: \"#{cancan_action}\").first"
  # p '----------------------------------------------------------------------'

  permission  = Permission.where(subject_class: class_name, action: cancan_action).first

  if not permission
    permission = Permission.new
    permission.subject_class =  class_name
    permission.action = cancan_action
    permission.name = name
    permission.description = description
    permission.save
  else
    permission.name = name
    permission.description = description
    permission.save
  end
end
