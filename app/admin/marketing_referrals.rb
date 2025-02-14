ActiveAdmin.register MarketingReferral do

  permit_params :display_marketing_referral, :amd_marketing_referral, :active, :order, :phone_number

  controller do
    def scoped_collection
      MarketingReferral.unscoped
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :display_marketing_referral
      f.input :amd_marketing_referral
      f.input :order
      f.input :active
      f.input :phone_number
    end
    f.actions
  end
  
end
