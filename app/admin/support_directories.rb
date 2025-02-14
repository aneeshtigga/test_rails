ActiveAdmin.register SupportDirectory do
  actions :all, except: [:new, :create, :destroy]

  controller do
    def scoped_collection
      SupportDirectory.unscoped
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :cbo, input_html: { disabled: true }
      f.input :license_key, input_html: { disabled: true }

      f.input :location
      f.input :intake_call_in_number
      f.input :support_hours
      f.input :state
    end
    f.actions
  end

  permit_params :location, :intake_call_in_number, :support_hours, :state
end
