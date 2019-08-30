ActiveAdmin.register CommunityImage do
  menu parent: 'Communities'

  permit_params :community_id, :caption, :tags, :sort_order, :published

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :community_id, :caption, :tags, :sort_order, :published
  #
  # or
  #
  # permit_params do
  #   permitted = [:community_id, :caption, :tags, :sort_order, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    selectable_column
    id_column

    column :name
    column :caption
    toggle_bool_column :published
    column :created_at
    column :updated_at
    column :community

    actions
  end

  form do |f|
    min = CommunityImage.minimum('sort_order')
    max = CommunityImage.maximum('sort_order')
    max = 9999 if max < 10
    min = 0 if min == max

    f.inputs do
      f.input :published
      f.input :image, hint: image_tag(url_for(resource.image), size: '300')
      f.input :caption
      f.input :tags, as: :tags, collection: CommunityImage.all_tags
      f.input :sort_order, as: :range, min: min, max: max, step: 1, hint: "#{resource.sort_order.to_s}", input_html: {
        oninput: %q(document.querySelector("#community_image_sort_order_input > p").innerHTML = this.valueAsNumber)
      }
      f.input :community_id, as: :search_select, url: activeadmin_communities_path,
          fields: [:name], display_name: 'name', minimum_input_length: 1,
          order_by: 'id_desc'
    end

    f.actions
  end
end
