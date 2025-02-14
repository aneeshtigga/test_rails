module RequestHelpers
  def  json_response
    JSON.parse(response.body)
  end

  def token_encoded_get(path, params: {}, token: nil)
    get path, params: params, headers: headers(token: token)
  end

  def token_encoded_patch(path, params: {}, token: nil)
    patch path, params: params, headers: headers(token: token)
  end

  def token_encoded_post(path, params: {}, token: nil)
    post path, params: params, headers: headers(token: token)
  end

  def token_encoded_put(path, params: {}, token: nil)
    put path, params: params, headers: headers(token: token)
  end

  def headers(token: nil)
    { "Authorization" => "Bearer #{token}"}
  end
end
