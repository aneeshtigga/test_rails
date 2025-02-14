ActiveAdmin.register FeatureEnablement do
  actions :all, except: [:new, :create, :destroy]

  controller do
    def scoped_collection
      FeatureEnablement.unscoped
    end
  end
  
  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :state
      f.input :is_abie_active, wrapper_html: { style: "padding: 0;"}
      f.input :is_obie_active, wrapper_html: { style: "padding: 0;"}
      f.input :lifestance_state, wrapper_html: { style: "padding: 0;"}
    end
    f.actions
  end

  permit_params :state, :is_obie_active, :is_abie_active, :lifestance_state
  
end
