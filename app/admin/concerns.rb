ActiveAdmin.register Concern do
  actions :all, except: [:new, :create, :destroy]

  controller do
    def scoped_collection
      Concern.unscoped
    end

  end    

  index do
    selectable_column
    column :name
    column :age_type do |concern|
      if !concern.age_type
        if concern.active
          '<b style="color: red;">MISSING</b>'.html_safe
        else
          ''
        end
      elsif concern.age_type == 'self'
        'Adult'
      else
        concern.age_type&.capitalize
      end
    end
    column :active
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :age_type do |concern|
        if !concern.age_type
          'MISSING'
        elsif concern.age_type == 'self'
          'Adult'
        else
          concern.age_type&.capitalize
        end
      end
      row :active
      row :created_at
      row :updated_at
    end
  end
  
  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :name, input_html: { disabled: true }
      f.input :age_type, as: :select, include_blank: false, collection: [["Adult", "self"], ["Child", "child"], ["Both", "both"]]
      f.input :active, wrapper_html: { style: "padding: 0;"}
      f.input :created_at, input_html: { disabled: true }
      f.input :updated_at, input_html: { disabled: true }
    end
    f.actions
  end

  permit_params :active, :age_type
end
