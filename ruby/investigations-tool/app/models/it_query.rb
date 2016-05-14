class ITQuery

  APPROVED_QUERY_LIST = [
                          :observatory_search, :submit_query_interface_query,
                          :argh_search, :missing_rule_lookup, :bertha_job_details,
                          :file_ingest_details, :daily_billing_reads, :daily_ami_reads
                        ]

  # Returns a list of all available searches
  def self.get_available_queries
    begin
      /REDACTED/_queries = /REDACTED/.get_queries
    rescue => e
      return ITResponse.new(errors: "ERROR - #{e.message} was received while getting /REDACTED/ Queries")
    end

    queries = /REDACTED/_queries.map do |query|
      {
        name: query[:name],
        method: /REDACTED/,
        async: true,
        description: query[:description],
        options: query[:options],
        additional_info: {
          classname: query[:classname]
        }
      }
    end

    queries << {
      name:         '/REDACTED/',
      method:       /REDACTED/,
      async:        false,
      description:  '/REDACTED/'
    }

    queries << {
      name:         '/REDACTED/',
      method:       /REDACTED/,
      async:        false,
      description:  '/REDACTED/'
    }

    queries << {
        name:        '/REDACTED/',
        method:      /REDACTED/,
        description: '/REDACTED/',
        options:     ['uuid']
    }
/REDACTED/
    ITResponse.new(result: queries)
  end

/REDACTED/

  def self./REDACTED/(params)
    begin
      if params[:options][:uuid].nil?
        details = /REDACTED/.submit_query( params[:query]['name'],
                                                            params[:query]['additional_info']['classname'], params[:options])
      else
        details = /REDACTED/.get_query_status(params[:options][:uuid])
      end
      ITResponse.new(**details)
    rescue => e
      ITResponse.new(errors: "ERROR - Received #{e.message} while running /REDACTD/ query")
    end
  end

  def self.get_query_response(method, query, options)
    if APPROVED_QUERY_LIST.include?(method.to_sym)
      self.method(method).call(query: query, options: options)
    else
      ITResponse.new(errors: "ERROR - Method #{method} is not on approved query list")
    end
  end
end
