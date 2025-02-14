class ExpertiseMart < DataWarehouse
  self.table_name = "clinician_mart.dim_clinician_focus_area"
  self.table_name = "clinician_focus_area" if Rails.env.development? || Rails.env.test?

  default_scope { where(focus_area_type: 'expertise') }

  def expertise_info
    {
      focus_area_name: focus_area_name,
      focus_area_type: focus_area_type,
      is_active: is_active
    }
  end
end
