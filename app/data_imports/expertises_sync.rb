class ExpertisesSync
  def self.import_data(time_since: nil)
    new.import_data(time_since: time_since)
  end

  def import_data(time_since: nil)
    expertises_data = expertises_data(time_since)

    expertises_data.each do |each_expertise_record|
      expertise_name = each_expertise_record.focus_area_name

      if each_expertise_record.is_active
        Expertise.find_or_create_by(name: expertise_name)
      else
        # Need to update all records with same name, but case might be different
        get_expertises_by(expertise_name)&.update(active: false)
      end
    end
  end

  private

  def expertises_data(time_since)
    if time_since.present?
      ExpertiseMart.where('load_date >= ?', time_since)
    else
      ExpertiseMart.all
    end
  end

  def get_expertises_by(name)
    Expertise.where('lower(name)= lower(?)', name)
  end
end
