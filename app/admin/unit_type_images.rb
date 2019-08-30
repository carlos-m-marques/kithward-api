ActiveAdmin.register UnitTypeImage, as: 'UnitLayoutImage' do
  menu parent: 'Communities'

  permit_params :unit_type_id, :caption, :tags, :sort_order, :published

  index do
    selectable_column
    id_column

    column :name
    column :caption
    toggle_bool_column :published
    column :created_at
    column :updated_at
    column 'Unit Layout', :unit_type

    actions
  end

  form do |f|
    min = UnitTypeImage.minimum('sort_order')
    max = UnitTypeImage.maximum('sort_order')
    max = 9999 if max < 10
    min = 0 if min == max

    f.inputs do
      f.input :published
      f.input :image, hint: image_tag(url_for(resource.image), size: '300')
      f.input :caption
      f.input :tags, as: :tags, collection: UnitTypeImage.all_tags
      f.input :sort_order, as: :range, min: min, max: max, step: 1, hint: "#{resource.sort_order.to_s}", input_html: {
        oninput: %q(document.querySelector("#unit_type_image_sort_order_input > p").innerHTML = this.valueAsNumber)
      }
      f.input :unit_type_id, as: :search_select, url: activeadmin_communities_path,
          fields: [:name], display_name: 'name', minimum_input_length: 1,
          order_by: 'id_desc'
    end

    f.actions
  end

end
