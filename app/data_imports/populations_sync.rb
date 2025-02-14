class PopulationsSync
  def self.import_data(time_since: Time.zone.now - 1.day)
    new.import_data(time_since: time_since)
  end

  def import_data(time_since: nil)
    populations_data = populations_data(time_since)

    populations_data.each do |each_population_record|
      population_name = each_population_record.focus_area_name

      unless each_population_record.is_active
        # Need to update all records with same name, but case might be different
        get_populations_by(population_name)&.update_all(active: each_population_record.is_active)
      else
        Population.find_or_create_by(name: population_name)
      end
    end
  end

  private

  def populations_data(time_since)
    unless time_since.present?
      PopulationsMart.all
    else
      PopulationsMart.where('load_date >= ?', time_since)
    end
  end

  def get_populations_by(name)
    Population.where('lower(name)= lower(?)', name)
  end
end
