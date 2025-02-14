ActiveAdmin.register HolidaySchedule do
  actions :all, except: [:destroy]

  permit_params :state, :date, :workday, :description

  controller do
    def scoped_collection
      HolidaySchedule.unscoped
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Details' do
      f.input :state, as: :select, include_blank: false, collection: State.all.pluck(:name)
      f.input :date, as: :date_select, include_blank: false, selected: Time.zone.today
      f.input :workday
      f.input :description
    end
    f.actions
  end

end
