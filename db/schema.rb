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

ActiveRecord::Schema.define(version: 2024_10_14_144852) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "cube"
  enable_extension "earthdistance"
  enable_extension "plpgsql"

  create_table "account_holders", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "date_of_birth", null: false
    t.string "gender", null: false
    t.string "phone_number"
    t.string "source"
    t.boolean "receive_email_updates", default: false
    t.boolean "email_verification_sent", default: false
    t.jsonb "search_filter_values", default: {}
    t.boolean "email_verified", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "amd_account_holder_id"
    t.string "pronouns"
    t.text "about"
    t.integer "responsible_party_id"
    t.jsonb "selected_slot_info", default: {}
    t.string "booked_by", default: "patient"
    t.string "gender_identity", default: "", null: false, comment: "Gender Identity is Protected Health Information (PHI) according to Health Insurance Portability and Accountability Act of 1996 (HIPAA) Privacy Rules. Specifically, HIPAA prohibits the disclosure of protected health information about gender-affirming care without consent except in limited circumstances. One of these limited circumstances—where disclosure may be possible without a patient's consent—is when disclosure is required under another law. \n\n In therapy sessions, the term \"gender identity\" is commonly used to refer to an individual's internal sense of their own gender, which may or may not align with the sex they were assigned at birth. Therapists may work with individuals to explore and understand their gender identity, and to help them navigate any challenges or difficulties they may face as a result of their gender identity. This may involve discussing issues such as gender dysphoria, coming out, transitioning, and coping with discrimination or stigma. It is important to note that therapy sessions are confidential and the therapist will work with the individual to create a safe and supportive environment for exploring their gender identity."
    t.string "confirmation_email"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "address_types", force: :cascade do |t|
    t.integer "code"
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ahoy_messages", force: :cascade do |t|
    t.string "user_type"
    t.bigint "user_id"
    t.string "to"
    t.string "mailer"
    t.text "subject"
    t.datetime "sent_at"
    t.integer "patient_id"
    t.index ["to"], name: "index_ahoy_messages_on_to"
    t.index ["user_type", "user_id"], name: "index_ahoy_messages_on_user"
  end

  create_table "amd_api_sessions", force: :cascade do |t|
    t.string "office_code"
    t.string "redirect_url"
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "api_request_responses", force: :cascade do |t|
    t.json "payload", default: {}
    t.json "response", default: {}
    t.json "headers", default: {}
    t.string "url"
    t.datetime "time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "api_action"
    t.string "api_class"
    t.string "response_code"
    t.string "response_message"
    t.string "api_method_call"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "clinician_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "modality"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "clinician_address_id"
    t.string "type_of_care"
    t.string "reason"
    t.bigint "clinician_availability_key"
    t.index ["clinician_address_id"], name: "index_appointments_on_clinician_address_id"
    t.index ["clinician_id"], name: "index_appointments_on_clinician_id"
  end

  create_table "audit_jobs", force: :cascade do |t|
    t.string "job_name"
    t.json "params", default: {}
    t.json "audit_data", default: {}
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "availability_block_out_rules", force: :cascade do |t|
    t.integer "hours"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "birdeye_appointments", force: :cascade do |t|
    t.bigint "appointment_id"
    t.string "facility_provider_reference"
    t.string "birdeye_business_id"
    t.string "patient_first_name"
    t.string "patient_last_name"
    t.string "campaign_type"
    t.string "email"
    t.string "phone"
    t.bigint "license_key"
    t.bigint "cbo"
    t.datetime "appointment_date"
    t.datetime "sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider_first_name"
    t.string "provider_last_name"
    t.string "NPI"
    t.string "clinician_type"
  end

  create_table "cancellation_reasons", force: :cascade do |t|
    t.string "reason"
    t.string "reason_equivalent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cancellations", force: :cascade do |t|
    t.string "cancelled_by"
    t.bigint "cancellation_reason_id"
    t.bigint "patient_appointment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cancellation_reason_id"], name: "index_cancellations_on_cancellation_reason_id"
    t.index ["patient_appointment_id"], name: "index_cancellations_on_patient_appointment_id"
  end

  create_table "clinician_accepted_ages", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "min_accepted_age"
    t.integer "max_accepted_age"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_accepted_ages_on_clinician_id"
    t.index ["max_accepted_age"], name: "index_clinician_accepted_ages_on_max_accepted_age"
    t.index ["min_accepted_age"], name: "index_clinician_accepted_ages_on_min_accepted_age"
  end

  create_table "clinician_addresses", force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "postal_code"
    t.bigint "clinician_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "address_code"
    t.bigint "office_key"
    t.bigint "facility_id"
    t.boolean "primary_location", default: true
    t.string "facility_name"
    t.string "apt_suite"
    t.string "country_code"
    t.string "area_code"
    t.bigint "provider_id"
    t.datetime "deleted_at"
    t.integer "cbo"
    t.float "latitude"
    t.float "longitude"
    t.index ["clinician_id"], name: "index_clinician_addresses_on_clinician_id"
    t.index ["deleted_at"], name: "index_clinician_addresses_on_deleted_at"
    t.index ["postal_code", "deleted_at"], name: "index_clinician_addresses_on_postal_code_and_deleted_at"
    t.index ["postal_code"], name: "index_clinician_addresses_on_postal_code"
    t.index ["provider_id", "facility_id", "office_key"], name: "index_clinician_addresses_on_pid_fid_lk"
  end

  create_table "clinician_availability", id: false, force: :cascade do |t|
    t.integer "clinician_availability_key"
    t.bigint "license_key"
    t.integer "profile_id"
    t.integer "column_id"
    t.integer "provider_id"
    t.string "npi"
    t.integer "facility_id"
    t.datetime "available_date"
    t.string "reason"
    t.datetime "appointment_start_time"
    t.datetime "appointment_end_time"
    t.string "type_of_care"
    t.integer "virtual_or_video_visit"
    t.integer "in_person_visit"
    t.integer "rank_most_available"
    t.integer "rank_soonest_available"
    t.bigint "is_ia", default: 1
    t.bigint "is_fu", default: 1
    t.string "tele_color"
    t.string "in_person_color"
    t.index ["facility_id"], name: "index_clinician_availability_on_facility_id"
    t.index ["license_key"], name: "index_clinician_availability_on_license_key"
    t.index ["provider_id"], name: "index_clinician_availability_on_provider_id"
  end

  create_table "clinician_availability_statuses", force: :cascade do |t|
    t.bigint "clinician_availability_key", null: false
    t.datetime "available_date", null: false
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "clinician_concerns", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "concern_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_concerns_on_clinician_id"
    t.index ["concern_id"], name: "index_clinician_concerns_on_concern_id"
  end

  create_table "clinician_expertises", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "expertise_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_expertises_on_clinician_id"
    t.index ["expertise_id"], name: "index_clinician_expertises_on_expertise_id"
  end

  create_table "clinician_interventions", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "intervention_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_interventions_on_clinician_id"
    t.index ["intervention_id"], name: "index_clinician_interventions_on_intervention_id"
  end

  create_table "clinician_languages", force: :cascade do |t|
    t.bigint "clinician_id"
    t.bigint "language_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_languages_on_clinician_id"
    t.index ["language_id"], name: "index_clinician_languages_on_language_id"
  end

  create_table "clinician_license_types", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "license_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_license_types_on_clinician_id"
    t.index ["license_type_id"], name: "index_clinician_license_types_on_license_type_id"
  end

  create_table "clinician_populations", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "population_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_populations_on_clinician_id"
    t.index ["population_id"], name: "index_clinician_populations_on_population_id"
  end

  create_table "clinician_special_cases", force: :cascade do |t|
    t.integer "clinician_id"
    t.integer "special_case_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinician_id"], name: "index_clinician_special_cases_on_clinician_id"
    t.index ["special_case_id"], name: "index_clinician_special_cases_on_special_case_id"
  end

  create_table "clinicians", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "clinician_type"
    t.string "license_type"
    t.text "about_the_provider"
    t.boolean "accepting_new_patients", default: false
    t.boolean "in_office", default: false
    t.boolean "video_visit", default: false
    t.boolean "manages_medication", default: false
    t.string "ages_accepted"
    t.integer "provider_id", null: false
    t.string "npi", null: false
    t.string "telehealth_url"
    t.string "gender"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "pronouns"
    t.datetime "deleted_at"
    t.string "middle_name"
    t.string "photo"
    t.integer "license_key"
    t.integer "cbo"
    t.datetime "online_booking_go_live_date"
    t.boolean "supervised_clinician", comment: "Check if clinician is supervised"
    t.string "supervisory_disclosure", comment: "Clinician supervisory disclosure to inform the patient"
    t.string "supervisory_type", comment: "Supervisory type can be billable, clinical or blank"
    t.text "supervising_clinician", comment: "Json will list the supervising clinician(s)"
    t.boolean "display_supervised_msg", comment: "will be used the patient needs to be informed and display\n                                                                                                    clinician disclosure message"
    t.index ["deleted_at"], name: "index_clinicians_on_deleted_at"
    t.index ["provider_id", "license_key"], name: "index_clinicians_on_provider_id_and_license_key"
  end

  create_table "concerns", force: :cascade do |t|
    t.string "name"
    t.integer "age_type"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "confirmation_tokens", force: :cascade do |t|
    t.string "token"
    t.bigint "account_holder_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "expire_at"
    t.index ["token"], name: "index_confirmation_tokens_on_token", unique: true
  end

  create_table "consent_forms", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "name", null: false
    t.integer "age_type"
    t.string "state_abbreviation"
    t.integer "content_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "rank"
  end

  create_table "educations", force: :cascade do |t|
    t.string "reference_type"
    t.integer "graduation_year"
    t.string "degree"
    t.bigint "clinician_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "university", null: false
    t.string "state"
    t.string "city"
    t.string "country"
    t.index ["clinician_id"], name: "index_educations_on_clinician_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "relationship_to_patient"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "patient_id"
    t.bigint "amd_contact_id"
    t.bigint "amd_relationship_to_patient_id"
    t.bigint "amd_phone_id"
    t.bigint "amd_instance_id"
    t.index ["patient_id"], name: "index_emergency_contacts_on_patient_id"
  end

  create_table "expertises", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
  end

  create_table "facility_accepted_insurances", force: :cascade do |t|
    t.integer "insurance_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "clinician_address_id"
    t.bigint "clinician_id"
    t.boolean "active", default: true
    t.string "supervisors_name", comment: "Supervisor's name"
    t.string "license_number", comment: "License number alphanumeric"
    t.index ["active"], name: "index_facility_accepted_insurances_on_active"
    t.index ["clinician_address_id", "active"], name: "index_facility_insurance_addresses"
    t.index ["clinician_address_id"], name: "index_facility_accepted_insurances_on_clinician_address_id"
    t.index ["clinician_id"], name: "index_facility_accepted_insurances_on_clinician_id"
    t.index ["insurance_id"], name: "index_facility_accepted_insurances_on_insurance_id"
  end

  create_table "feature_enablements", force: :cascade do |t|
    t.string "state", null: false
    t.boolean "is_obie_active", default: true
    t.boolean "is_abie_active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "lifestance_state", default: true
  end

  create_table "gender_identities", comment: "Gender Identity (GI) is how the patient views their own gender. This may or may not be the same as the gender to which they were born. The table is a mapping (cross-reference) of the GI used within the ABIE/OBIE applications with the GI that is used within the AMD 3rd party electronic health records (EHR) product.", force: :cascade do |t|
    t.string "gi", default: "", null: false, comment: "Gender Identity used within ABIE/OBIE"
    t.integer "amd_gi_ident", default: 0, null: false, comment: "This is the way that AMD identifies this GI in it's database. It is also the value that AMD expects in it's patient API."
    t.string "amd_gi", default: "", null: false, comment: "Gender Identity used within AMD"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["amd_gi"], name: "index_gender_identities_on_amd_gi", unique: true
    t.index ["amd_gi_ident"], name: "index_gender_identities_on_amd_gi_ident", unique: true
    t.index ["gi"], name: "index_gender_identities_on_gi", unique: true
  end

  create_table "hipaa_relationship_codes", force: :cascade do |t|
    t.integer "code"
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "holiday_schedules", comment: "HolidaySchedule establishes the days when the clinician offices are closed to observe a holiday.\n                          The observed holiday can be global for all states when the value of the state column is 'all' or\n                          specific to a single state. Only full days are taken off.", force: :cascade do |t|
    t.string "state", default: "All", comment: "Global “All” for every state, and then state for specific state holidays"
    t.date "date"
    t.boolean "workday", default: false, comment: "Whether it is a workday, (active)"
    t.string "description", comment: "Name or description for holiday"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "insurance_coverages", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "member_id", null: false
    t.string "group_id"
    t.string "relation_to_policy_holder"
    t.bigint "policy_holder_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "mental_health_phone_number"
    t.bigint "patient_id"
    t.integer "amd_id"
    t.integer "facility_accepted_insurance_id"
    t.string "amd_front_card_view_id"
    t.string "amd_back_card_view_id"
    t.datetime "amd_updated_at"
    t.index ["patient_id"], name: "index_insurance_coverages_on_patient_id"
    t.index ["policy_holder_id"], name: "index_insurance_coverages_on_policy_holder_id"
  end

  create_table "insurance_rules", force: :cascade do |t|
    t.boolean "skip_option_flag", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "insurances", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "mds_carrier_id"
    t.string "mds_carrier_name"
    t.integer "amd_carrier_id"
    t.string "amd_carrier_name"
    t.string "amd_carrier_code"
    t.string "license_key"
    t.boolean "amd_is_active", default: true
    t.boolean "is_active", default: true
    t.boolean "obie_external_display", default: true
    t.boolean "abie_intake_internal_display", default: true
    t.boolean "website_display", default: true
    t.date "enrollment_effective_from"
    t.string "carrier_name"
    t.string "carrier_id"
    t.index ["amd_is_active"], name: "index_insurances_on_amd_is_active"
  end

  create_table "intake_addresses", force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "postal_code"
    t.string "intake_addressable_type", null: false
    t.bigint "intake_addressable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["intake_addressable_type", "intake_addressable_id"], name: "index_intake_addresses_on_intake_addressable"
  end

  create_table "interventions", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "license_key_rules", force: :cascade do |t|
    t.string "rule_name"
    t.boolean "active", default: true
    t.integer "license_key_id"
    t.string "ruleable_type"
    t.integer "ruleable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["license_key_id"], name: "index_license_key_rules_on_license_key_id"
    t.index ["rule_name"], name: "index_license_key_rules_on_rule_name"
    t.index ["ruleable_id"], name: "index_license_key_rules_on_ruleable_id"
    t.index ["ruleable_type"], name: "index_license_key_rules_on_ruleable_type"
  end

  create_table "license_keys", force: :cascade do |t|
    t.bigint "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.bigint "cbo", comment: "A license key has one and only one CBO; however a CBO can have multiple license keys"
    t.string "state", comment: "Abbreviated State Code associated with the license key"
    t.index ["cbo"], name: "index_license_keys_on_cbo"
    t.index ["key"], name: "index_license_keys_on_key", unique: true
  end

  create_table "license_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_license_types_on_name"
  end

  create_table "marketing_referrals", force: :cascade do |t|
    t.string "display_marketing_referral", comment: "String being sent by the Front-end"
    t.string "amd_marketing_referral", comment: "String being sent to AMD"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true, comment: "Active if it should be shown"
    t.integer "order", comment: "Display order for marketing referrals"
    t.string "phone_number", comment: "Marketing Referral phone number"
  end

  create_table "patient_appointments", force: :cascade do |t|
    t.bigint "clinician_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "appointment_id", null: false
    t.integer "status"
    t.text "appointment_note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "clinician_address_id"
    t.integer "amd_appointment_id"
    t.string "booked_by", default: "patient"
    t.integer "cbo"
    t.integer "license_key"
    t.index ["appointment_id"], name: "index_patient_appointments_on_appointment_id"
    t.index ["clinician_address_id"], name: "index_patient_appointments_on_clinician_address_id"
    t.index ["clinician_id"], name: "index_patient_appointments_on_clinician_id"
    t.index ["patient_id"], name: "index_patient_appointments_on_patient_id"
  end

  create_table "patient_consents", force: :cascade do |t|
    t.integer "consent_form_id"
    t.integer "account_holder_id"
    t.integer "patient_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "amd_file_id"
    t.datetime "amd_updated_at"
  end

  create_table "patient_disorders", force: :cascade do |t|
    t.bigint "concern_id"
    t.bigint "patient_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "population_id"
    t.integer "intervention_id"
    t.index ["concern_id"], name: "index_patient_disorders_on_concern_id"
    t.index ["patient_id"], name: "index_patient_disorders_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "preferred_name"
    t.string "date_of_birth", null: false
    t.string "phone_number"
    t.string "referral_source"
    t.integer "account_holder_relationship", default: 0
    t.string "pronouns"
    t.text "about"
    t.bigint "special_case_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "search_filter_values"
    t.boolean "credit_card_on_file_collected", default: false
    t.integer "intake_status"
    t.bigint "amd_patient_id"
    t.bigint "account_holder_id"
    t.string "gender"
    t.integer "provider_id"
    t.integer "office_code"
    t.integer "marketing_referral_id"
    t.integer "profile_id"
    t.string "referring_provider_name"
    t.string "referring_provider_phone_number"
    t.string "email"
    t.datetime "amd_updated_at"
    t.string "gender_identity", default: "", null: false, comment: "Gender Identity is Protected Health Information (PHI) according to Health Insurance Portability and Accountability Act of 1996 (HIPAA) Privacy Rules. Specifically, HIPAA prohibits the disclosure of protected health information about gender-affirming care without consent except in limited circumstances. One of these limited circumstances—where disclosure may be possible without a patient's consent—is when disclosure is required under another law. \n\n In therapy sessions, the term \"gender identity\" is commonly used to refer to an individual's internal sense of their own gender, which may or may not align with the sex they were assigned at birth. Therapists may work with individuals to explore and understand their gender identity, and to help them navigate any challenges or difficulties they may face as a result of their gender identity. This may involve discussing issues such as gender dysphoria, coming out, transitioning, and coping with discrimination or stigma. It is important to note that therapy sessions are confidential and the therapist will work with the individual to create a safe and supportive environment for exploring their gender identity."
    t.boolean "amd_pronouns_updated", default: false
    t.index ["account_holder_id"], name: "index_patients_on_account_holder_id"
    t.index ["special_case_id"], name: "index_patients_on_special_case_id"
  end

  create_table "phreesia", force: :cascade do |t|
    t.integer "license_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "populations", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "postal_codes", force: :cascade do |t|
    t.string "zip_code"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "country_code"
    t.string "state_code"
    t.float "latitude"
    t.float "longitude"
    t.string "day_light_saving"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "time_zone"
    t.string "time_zone_abbr"
    t.bigint "utc_offset_sec"
    t.json "zip_codes_by_radius", default: {}
    t.index ["zip_code"], name: "index_postal_codes_on_zip_code"
  end

  create_table "responsible_parties", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "date_of_birth", null: false
    t.string "gender", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "amd_id"
    t.datetime "amd_updated_at"
  end

  create_table "rules", force: :cascade do |t|
    t.string "name"
    t.string "data_type"
    t.string "key"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "special_cases", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "age_type", default: 2
    t.datetime "deleted_at"
    t.index ["age_type"], name: "index_special_cases_on_age_type"
    t.index ["deleted_at"], name: "index_special_cases_on_deleted_at"
  end

  create_table "sso_audits", force: :cascade do |t|
    t.string "app_name"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.bigint "expiration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sso_tokens", force: :cascade do |t|
    t.string "token"
    t.jsonb "data", default: {}
    t.datetime "expire_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token"], name: "index_sso_tokens_on_token", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "full_name"
  end

  create_table "support_directories", force: :cascade do |t|
    t.integer "cbo", null: false
    t.integer "license_key", null: false
    t.string "location"
    t.string "intake_call_in_number"
    t.string "support_hours"
    t.string "established_patients_call_in_number"
    t.string "follow_up_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state"
  end

  create_table "type_of_cares", force: :cascade do |t|
    t.integer "amd_license_key", null: false
    t.integer "amd_appt_type_uid", null: false
    t.boolean "in_person_visit", default: false
    t.boolean "virtual_or_video_visit", default: false
    t.string "amd_appointment_type"
    t.string "type_of_care", null: false
    t.string "age_group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "facility_id", null: false
    t.bigint "clinician_id", null: false
    t.integer "cbo"
    t.index ["amd_license_key"], name: "index_type_of_cares_on_amd_license_key"
    t.index ["clinician_id"], name: "index_type_of_cares_on_clinician_id"
    t.index ["facility_id"], name: "index_type_of_cares_on_facility_id"
    t.index ["type_of_care"], name: "index_type_of_cares_on_type_of_care"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "provider", default: "saml", null: false
    t.string "saml_uid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["saml_uid"], name: "index_users_on_saml_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "clinicians"
  add_foreign_key "cancellations", "cancellation_reasons"
  add_foreign_key "cancellations", "patient_appointments"
  add_foreign_key "clinician_addresses", "clinicians"
  add_foreign_key "educations", "clinicians"
  add_foreign_key "emergency_contacts", "patients"
  add_foreign_key "facility_accepted_insurances", "clinician_addresses"
  add_foreign_key "patient_appointments", "appointments"
  add_foreign_key "patient_appointments", "clinicians"
  add_foreign_key "patient_appointments", "patients"
  add_foreign_key "type_of_cares", "clinicians"
end
