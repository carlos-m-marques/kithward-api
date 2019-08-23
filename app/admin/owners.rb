ActiveAdmin.register Owner do
  menu parent: 'Pm Systems'

  permit_params :name, :address1, :address2, :city, :state, :zip, :pm_system_id
end
