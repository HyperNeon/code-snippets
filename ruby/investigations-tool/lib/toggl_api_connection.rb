module TogglAPIConnection
  module_function

  def start_time(token, description, tags = [])
    url = 'https://www.toggl.com/api/v8/time_entries/start'
    pid = /REDACTED/
    auth = {:username => token, :password => "api_token"}
    params = {
      "time_entry" => {
        "description" => description,
        "tags" => tags,
        "pid" => pid,
        "billable" => true,
        "created_with" => "Investigations Tool"
      }
    }

    JSON.parse HTTParty.get(url, :headers => {'Content-Type' => 'application/json'}, basic_auth: auth, body: params.to_json).body
  end

end