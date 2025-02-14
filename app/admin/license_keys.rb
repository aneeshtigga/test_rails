ActiveAdmin.register LicenseKey do
  actions :all, except: [:new, :create, :destroy]

  controller do
    def scoped_collection
      LicenseKey.unscoped
    end
  end
  
  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :key, input_html: { disabled: true }
      f.input :active, wrapper_html: { style: "padding: 0;"}
      f.input :state
    end
    f.actions
  end

  permit_params :active, :state
  
end
