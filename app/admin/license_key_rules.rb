ActiveAdmin.register LicenseKeyRule do
  actions :all, except: [:destroy]

  permit_params :rule_name, :active, :license_key_id, :ruleable_type, :ruleable_id

  controller do
    def scoped_collection
      LicenseKeyRule.unscoped
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :rule_name
      f.input :active, as: :boolean
      f.input :license_key_id
      f.input :ruleable_type, as: :select, collection: (['Rule', 'AvailabilityBlockOutRule', 'InsuranceRule']), include_blank: false
      f.input :ruleable_id
    end
    f.actions
  end

end
