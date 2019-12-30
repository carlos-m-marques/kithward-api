ActiveAdmin.register Community do
  permit_params :name, :description, :street, :street_more, :city, :state, :postal, :country, :lat, :lon, :care_type, :status, :data, :cached_image_url, :cached_data, :monthly_rent_lower_bound, :monthly_rent_upper_bound, :owner_id, :pm_system_id, :region, :metro, :borough, :county, :township, :deleted_at, :flagged_at, :flagged_for

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      # f.input :role, as: :select, include_blank: false, collection: Account::ROLES
      f.input :poi_ids, as: :selected_list, order_by: :id_desc, label: 'Points of Interest'
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      bool_row :flagged?
      # row :flagged_for
      row :street
      # row :street_more
      row :city
      row :state
      row :postal
      # row :country
      # row :lat
      # row :lon
      row :care_type_label
      row :monthly_rent_lower_bound
      row :monthly_rent_upper_bound
      # row :region
      # row :metro
      # row :borough
      # row :county
      # row :township
      attributes_table do
        list_row :community_kw_values
      end
      row :images do |community|
        community.community_images.map do |ci|
          if ci.content_type
            image_tag url_for(ci.image)
          end
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    bool_column :flagged?
    column :created_at
    tag_column :care_type_label
    actions
  end

  filter :name
  filter :created_at
  filter :updated_at
end
