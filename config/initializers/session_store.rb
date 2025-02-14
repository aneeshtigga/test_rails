Rails.application.config.session_store :active_record_store,
  key: '_lfst_session',
  secure: !(Rails.env.test?),
  http_only: false,
  same_site: :none,
  expire_after: 30.minutes