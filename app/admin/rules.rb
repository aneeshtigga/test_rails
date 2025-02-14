ActiveAdmin.register Rule do
  actions :all, except: [:destroy]

  permit_params :name, :data_type, :key, :value, :description

  controller do
    def scoped_collection
      Rule.unscoped
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :name, as: :select, collection: (['Availability Block Out', 'Credit Card', 'Insurance'])
      f.input :description
      f.input :data_type, as: :select, collection:  (['Boolean', 'Number', 'Text'])
      f.input :key
      f.input :value
    end
    f.actions
  end

end
