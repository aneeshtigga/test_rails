ActiveAdmin.register Insurance do
  actions :all, except: [:new, :create, :destroy]

  controller do
    def scoped_collection
      Insurance.unscoped
    end
  end
  
  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :name, input_html: { disabled: true }
      f.input :mds_carrier_id, input_html: { disabled: true }
      f.input :mds_carrier_name, input_html: { disabled: true }
      f.input :amd_carrier_id, input_html: { disabled: true }
      f.input :amd_carrier_name, input_html: { disabled: true }
      f.input :amd_carrier_code, input_html: { disabled: true }
      f.input :license_key, input_html: { disabled: true }
  
      f.input :is_active, wrapper_html: { style: "padding: 0;"}
    end
    f.actions
  end

  permit_params :is_active
  
end
