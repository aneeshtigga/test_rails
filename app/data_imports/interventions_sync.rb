class InterventionsSync
  def self.import_data(time_since: Time.zone.now - 1.day)
    new.import_data(time_since: time_since)
  end

  def import_data(time_since: nil)
    interventions_data = interventions_data(time_since)

    interventions_data.each do |each_intervention_record|
      intervention_name = each_intervention_record.focus_area_name

      unless each_intervention_record.is_active
        # Need to update all records with same name, but case might be different
        get_interventions_by(intervention_name)&.update_all(active: each_intervention_record.is_active)
      else
        Intervention.find_or_create_by(name: intervention_name)
      end
    end
  end

  private

  def interventions_data(time_since)
    unless time_since.present?
      InterventionsMart.all
    else
      InterventionsMart.where('load_date >= ?', time_since)
    end
  end

  def get_interventions_by(name)
    Intervention.where('lower(name)= lower(?)', name)
  end
end
