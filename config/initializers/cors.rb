Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:8080", /advancedmd.com/
    resource '/api/v1/auth',
      headers: :any,
      methods: [:post],
      expose: ['Set-Cookie'],
      credentials: true
    resource '/api/v1/logout', headers: :any, methods: [:delete]
  end

  allow do
    origins /digitallifestance.com/
    resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
  end

  allow do
    origins /lifestance.com/
    resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
  end
end
