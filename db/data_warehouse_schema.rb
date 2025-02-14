# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_06_18_122746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "carrier_insurances", force: :cascade do |t|
    t.bigint "license_key"
    t.bigint "clinician_id"
    t.bigint "facility_id"
    t.bigint "npi"
    t.integer "mds_carrier_id"
    t.string "mds_carrier_name"
    t.integer "amd_carrier_id"
    t.string "amd_carrier_name"
    t.string "amd_carrier_code"
    t.boolean "amd_is_active", default: true
    t.datetime "amd_create_timestamp"
    t.datetime "amd_change_timestamp"
    t.string "supervisors_name"
    t.string "license_number"
    t.boolean "obie_external_display"
    t.boolean "abie_intake_internal_display"
    t.boolean "website_display"
    t.date "enrollment_effective_from"
    t.string "carrier_name"
    t.string "carrier_id"
  end

  create_table "clinician_educations", force: :cascade do |t|
    t.string "referencetype"
    t.string "degree"
    t.integer "graduationyear"
    t.integer "npi", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "universityname", null: false
    t.string "universitycity"
    t.string "universitystate"
    t.string "universitycountry"
  end

  create_table "clinician_focus_area", force: :cascade do |t|
    t.string "focus_area_name"
    t.string "focus_area_type"
    t.boolean "is_active"
    t.datetime "load_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "clinician_location_marts", force: :cascade do |t|
    t.bigint "license_key"
    t.bigint "clinician_id"
    t.boolean "primary_location"
    t.string "facility_name"
    t.bigint "facility_id"
    t.string "apt_suite"
    t.string "location"
    t.string "zip_code"
    t.string "city"
    t.string "state"
    t.string "area_code"
    t.string "country_code"
    t.integer "is_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "create_timestamp"
    t.datetime "change_timestamp"
    t.integer "cbo"
  end

  create_table "type_of_care_appt_type", force: :cascade do |t|
    t.integer "amd_license_key"
    t.integer "amd_appt_type_uid"
    t.boolean "in_person_visit"
    t.boolean "virtual_or_video_visit"
    t.string "amd_appointment_type"
    t.string "type_of_care"
    t.string "age_group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "facility_id"
    t.bigint "clinician_id"
    t.integer "cbo"
  end

  create_table "vw_clinician_mart", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "clinician_type", null: false
    t.string "license_type", null: false
    t.string "expertise"
    t.text "about_the_provider"
    t.boolean "in_office"
    t.boolean "virtual_visit"
    t.boolean "manages_medication"
    t.string "ages_accepted"
    t.integer "clinician_id", null: false
    t.integer "npi", null: false
    t.integer "license_key"
    t.boolean "primary_location"
    t.string "location"
    t.string "zip_code"
    t.string "city"
    t.string "state"
    t.string "area_code"
    t.string "country_code"
    t.integer "cbo"
    t.text "telehealth_url"
    t.string "gender"
    t.string "languages"
    t.string "pronouns"
    t.datetime "create_timestamp", precision: 6, null: false
    t.datetime "change_timestamp", precision: 6, null: false
    t.string "middle_name"
    t.string "photo"
    t.string "facility_name"
    t.integer "facility_id"
    t.string "apt_suite"
    t.boolean "is_active"
    t.string "special_cases"
    t.string "intervention"
    t.string "population"
    t.string "concern"
    t.boolean "supervised_clinician"
    t.string "supervisory_disclosure"
    t.string "supervisory_type"
    t.text "supervising_clinician"
    t.boolean "display_supervised_msg"
    t.datetime "load_date"
  end

end
