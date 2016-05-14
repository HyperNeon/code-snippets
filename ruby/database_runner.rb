module DatabaseRunner
  module_function
  
  # Connect to Elasticsearch Database
  def connect_to_importer(client_code)
    if client_code.include?("/REDACTED/") || client_code.include?("/REDACTED/") || client_code.include?("/REDACTED/")
      importer_host = Elasticsearch::Client.new host: '/REDACTED/:9200/', retry_on_failure: true
    else
      importer_host = Elasticsearch::Client.new host: '/REDACTED/:9200/', retry_on_failure: true
    end
  end
  
  # Query the /REDACTED/ or /REDACTED/ databases
  # Returns Array of Hashes
  def query_db(db, qry)
    db = db.to_s.concat("_prod").to_sym if Rails.env.production?
    db = db.to_s.concat("_alpha").to_sym if Rails.env.alpha?
    connection_pool = ActiveRecord::Base::establish_connection db
    connection_pool.with_connection { |c| c.select_all(qry) }
  end

/REDACTED/
  
end