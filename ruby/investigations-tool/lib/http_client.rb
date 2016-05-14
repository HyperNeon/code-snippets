module HttpClient
  def self.check_http_200(code)
    code.to_i == 200 ? true : false
  end

  def self.get(params)
    response = nil
    with_retries(:max_retries => 5) do |attempt|
      raise params[:error_message] if attempt == 5
      response = HTTParty.get(params[:url])
    end
    raise "#{params[:error_message]}: \n Response Body: \n #{response.body}" unless HttpClient.check_http_200(response.code)
    JSON[response.body]
  end
end
