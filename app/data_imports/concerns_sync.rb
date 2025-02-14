class ConcernsSync
  def self.import_data(time_since: nil)
    new.import_data(time_since: time_since)
  end

  def import_data(time_since: nil)
    concerns_missing_age_type = []
    concerns_data = concerns_data(time_since)

    concerns_data.each do |dw_concern|
      concern_name = dw_concern.focus_area_name

      if dw_concern.is_active
        concern = Concern.unscoped.find_by(name: concern_name)
        if concern&.age_type
            concern.update(active: true) unless concern.active
        elsif concern
          # We found a concern with the same name but no age_type
          concerns_missing_age_type << concern_name
        else
          # We didn't find a concern with the same name. Create a new one but flag for missing age_type
          Concern.create(name: concern_name, active: false)
          concerns_missing_age_type << concern_name
        end
      else
        # Need to update all records with same name, but case might be different
        get_concerns_by(concern_name)&.update(active: false)
      end
    end

    # We found a concern with the same name but no age_type. Throw a RogueConcernException since staff
    # need to go into ActiveAdmin and add the age_type manually
    raise RogueConcernException, "Concerns missing age_type: #{concerns_missing_age_type.join(', ')}" if concerns_missing_age_type.present?
  end

  private

  def concerns_data(time_since)
    if time_since.present?
      ConcernMart.where('load_date >= ?', time_since)
    else
      ConcernMart.all
    end
  end

  def get_concerns_by(name)
    Concern.where('lower(name)= lower(?)', name)
  end
end
