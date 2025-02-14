ActiveAdmin.register Phreesia do
  actions :all

  permit_params :id, :license_key
end
