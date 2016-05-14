
require 'net/http'
require 'nokogiri'


class HTTPInteractor
  extend Classy
  class_attr_accessor :connection_pool
  attr_reader :base_url, :utility_code, :base_header

  LOGIN_DO = "/REDACTED/"
  LOGIN_URL = "/REDACTED/"
  CHECK_ELIGIBILITY_URL = '/REDACTD/'
  GENERATE_URL = "/REDACTED/"
  PRINT_JOB_URL = "/REDACTED/"
  PRINT_JOB_SINGLE_STEP_URL = "/REDACTED/"
  EXPORT_PRESORT_URL = "/REDACTED/"
  DELIVER_IN_HOUSE_URL = "/REDACTED/"
  DOWNLOAD_CASS_URL = "/REDACTED/"
  EMAIL_DELIVERY_URL = "/REDACTED/"
  DELIVER_PRINT_URL = "/REDACTED/"
  DELIVER_EMAIL_URL = "/REDACTED/"
  DELETE_BATCH_URL = "/REDACTED/"
  ROLL_BACK_URL = "/REDACTED/"
  COLLATE_BATCH = "/REDACTED/"
  @@connection_pool = {}
 
  class HTTPInteractorError < StandardError
    attr_reader :client, :operation, :url
    def initialize(client, message, operation, url)
      @client = client
      @message = message
      @operation = operation
      @url = url
      @formatted_message = "[#{Time.now}]-#{client.upcase}: #{message} was received while #{operation} via #{url}"
    end
    
    def to_s
      @formatted_message
    end
    
    def to_log
      # Remove the timestamp since the log automatically adds it
      @formatted_message.split("]-",2).last
    end
  end
  
  def initialize(utility_code)
    if Rails.env.production?
      @base_header = {'Host' => "/REDACTED/", '/REDACTED/-Source' => '/REDACTED/'}
      if utility_code.include?("/REDACTED/") || utility_code.include?("/REDACTED/") || utility_code.include?("/REDACTED/")
        @base_url = '/REDACTED//'
      else
        @base_url = '/REDACTED//'
      end

    elsif Rails.env.alpha?
      if utility_code.include?("/REDACTED/") || utility_code.include?("/REDACTED/") || utility_code.include?("/REDACTED/")
        @base_url = '/REDACTED//'
        @base_header = {'Host' => "/REDACTED/", '/REDACTED/-Source' => '/REDACTED/'}
      else
        @base_url = '/REDACTED//'
        @base_header = {'Host' => "/REDACTED/", '/REDACTED/-Source' => '/REDACTED/'}
      end

    else
      @base_header = {'Host' => "/REDACTED/", '/REDACTED/-Source' => '/REDACTED/'}
      if utility_code.include?("/REDACTED/") || utility_code.include?("/REDACTED/") || utility_code.include?("/REDACTED/")
        @base_url = '/REDACTED//'
      else
        @base_url = '/REDACTED//'
      end
    end

    @utility_code = utility_code
    @@connection_pool[@utility_code.to_sym] ||= {}
    @@connection_pool[@utility_code.to_sym].merge!(@base_header)
  end
  
  def check_print_eligibility
    uri = URI.parse("#{@base_url}#{CHECK_ELIGIBILITY_URL}")
    # Always uses tt_targetCustomersTable if available
    
    data = {}
    /REDACTED/

    data_string = create_data_string(data)
    @operation = "Checking Print Eligibility"
    run_http_command(uri, data_string)
  end
  
  def check_email_eligibility
    uri = URI.parse("#{@base_url}#{CHECK_ELIGIBILITY_URL}")
    # Always uses tt_targetCustomersTable if available
    
    data = {}
    /REDACTED/

    data_string = create_data_string(data)
    @operation = "Checking Email Eligibility"
    run_http_command(uri, data_string)
  end
  
  # Takes an array of print partition keys
  # param_options return key/value of :collated_batch => true or false, :volume_limiting => true or false
  def generate_print_reports( partition_keys, param_options={} )
    uri = URI.parse("#{@base_url}#{GENERATE_URL}")
    collated_batch = param_options[:collated_batch] ||= false
    volume_limiting = param_options[:volume_limiting] ||= false
    
    # Always uses tt_targetCustomersTable if available  
    data = {}
    /REDACTED/
    data_string = create_data_string(data)

    # Loop through each key and append it to the form data if active using the index to identify the print batch
    partition_keys.each_with_index do |key, i|
      /REDACTED/
    end
    @operation = "Generating Print Reports"
    run_http_command(uri, data_string)
  end
  
  def generate_email_reports
    uri = URI.parse("#{@base_url}#{GENERATE_URL}")
    
    # Always uses tt_targetCustomersTable if available
    data = {}
    /REDACTED/
    
    data_string = create_data_string(data)
    @operation = "Generating Email Reports"
    run_http_command(uri, data_string)
  end
  
  def single_step_work_flow
    uri = URI.parse("#{@base_url}#{PRINT_JOB_SINGLE_STEP_URL}")
    data = "/REDACTED/"
    @operation = "Running Single Step Work Flow"
    run_http_command(uri, data)
  end
  
  def export_to_presort
    uri = URI.parse("#{@base_url}#{EXPORT_PRESORT_URL}")
    data = "/REDACTED/"
    @operation = "Exporting To Presort"
    run_http_command(uri, data)
  end
    
  def deliver_in_house(job_id)
    uri = URI.parse("#{@base_url}#{DELIVER_IN_HOUSE_URL}")
    data = "/REDACTED/"
    @operation = "Delivering In House"
    run_http_command(uri, data)
  end
  
  def download_cass(job_id)
    uri = URI.parse("#{@base_url}#{DOWNLOAD_CASS_URL}")
    data = "/REDACTED/"
    @operation = "Downloading CASS"
    run_http_command(uri, data)
  end
  
  def deliver_print(job_id)
    uri = URI.parse("#{@base_url}#{DELIVER_PRINT_URL}")
    data = "/REDACTED/"
    @operation = "Delivering Print"
    run_http_command(uri, data)
  end
  
  def deliver_email
    uri = URI.parse("#{@base_url}#{DELIVER_EMAIL_URL}")
    data = "/REDACTED/"
    @operation = "Delivering Email"
    run_http_command(uri, data)
  end
  
  def delete_batch(batch_id, reason)
    uri = URI.parse("#{@base_url}#{DELETE_BATCH_URL}")
    data = "/REDACTED/"
    @operation = "Deleting Batch"
    run_http_command(uri, data)
  end
  
  def roll_back_print_job(print_job_id, reason)
    uri = URI.parse("#{@base_url}#{ROLL_BACK_URL}")
    data = "/REDACTED/"
    @operation = "Rolling Back Print Job"
    run_http_command(uri, data)
  end
  
  def collate_batch(batch_id)
    uri = URI.parse("#{@base_url}#{COLLATE_BATCH}")
    data = "/REDACTED/"
    @operation = "Collating Batch"
    run_http_command(uri, data)    
  end
  
  # Attempt to run http command, if redirected to login page, login first, then run command
  def run_http_command(uri, data)
    
    http = new_http(uri)

    # If command doesn't go through try logging in and retry, max attempts 5
    attempt = 0
    max_attempts = 5
    catch :command_successful do
      while attempt < max_attempts
        attempt+=1
        header = @@connection_pool[@utility_code.to_sym]
        
        # Some commands, specifically Download CASS, run synchronously and do not return at all until it has finished
        # or errored out, which would both take too long to wait for and thus ruby throws a timeout error. Let's catch
        # this error and since it's not a 504 Timeout or 404 Error we can assume the command went through and the server
        # is just taking a long time to process.
        begin
          response = http.post(uri.path, data, header)
        rescue Timeout::Error => e
          Rails.logger.info "Timeout Reached when waiting for #{uri.to_s} - Assuming command successful"
          throw :command_successful 
        rescue => e
          raise HTTPInteractorError.new(@utility_code, "/REDACTED/ connection failed with #{e.class} - #{e.to_s}", @operation, uri.to_s)
        end
        
        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          # If response location contains a location that is not a login page, the command was successful
          new_location = response.header['location']
          if new_location
            # Some clients have redirects to url that are different then their client code, if the host we get in the location is
            # different then the current host, then update the host. Since this would also catch sso redirects and clients
            # that have both unique names and sso always give us the 301 name redirect before the 302 sso redirect, let's 
            # exclude any url's with sso from this check entirely
            original_host = @@connection_pool[@utility_code.to_sym]['Host']
            new_host = URI(new_location).host
            if original_host != new_host && !new_location.include?('sso') && !new_location.include?('maintenance')
              Rails.logger.debug "Original /REDACTED/ host is: #{original_host}"
              @@connection_pool[@utility_code.to_sym]['Host'] = new_host
              @base_header['Host'] = new_host
              Rails.logger.debug "New /REDACTED/ host is: #{new_host}"
            else
              if new_location.include?('/user/login.do') || new_location.include?('sso')
                # trying to redirect back to login or SSO auth page
                login
              elsif new_location.include?('maintenance')
                raise HTTPInteractorError.new(@utility_code, "/REDACTED/ Unavailable 503 Error", @operation, uri.to_s)
              else 
                throw :command_successful
              end
            end
                  
          # Response header from eligibility page does not return a redirect location
          # Instead it contains an x-frame-options['SAMEORIGIN'], since in page validation errors
          # do the same thing, need to make sure this page is not returning an error
          elsif response.header['x-frame-options'].present? && !response.body.include?("class=\"error\"")
            throw :command_successful
          elsif response.body.include?("class=\"error\"")
            # If the command wasn't successful, and we're not getting a location redirect
            # /REDACTED/ has most likely thrown an error, parse the error out of the page and truncate after 500 characters
            # just in case it's displaying a stacktrace
            error_message = response.body.slice(/<.*class="error">[\s\S]*?<.*>/)
            # Ignore the QA assisting table message that sometimes appears on rep gen page since it's not a real error
            if error_message.include?("There is a QA-assisting table (tt_target_batch_customers)")
              Rails.logger.warn "There is a QA-assisting table (tt_target_batch_customers) for #{@utility_code} on #{@base_url}"
              throw :command_successful
            else
              raise HTTPInteractorError.new(@utility_code, error_message[0..500], @operation, uri.to_s)
            end
          end
        when Net::HTTPForbidden # Invalid csrf token. Need to login
          login
        else
          # We're getting some other unexpected HTTP response, so let's raise a /REDACTED/ error
          raise HTTPInteractorError.new(@utility_code, response.code_type.to_s + " " + response.code , @operation, uri.to_s)
        end
      end
      raise HTTPInteractorError.new(@utility_code, '/REDACTED/ Connection Failed After 5 Attempts', @operation, uri.to_s)
    end 
  end
  
  
  def login
    uri = URI.parse("#{@base_url}#{LOGIN_DO}")
    http = new_http(uri)
    Rails.logger.info "Attempting to login to #{@utility_code}"
    # Resetting header to clear out stale cookies and CSRF token since we're logging in again
    @@connection_pool[@utility_code.to_sym] = @base_header
    # Adding code to parse the csrf token out of the login page before trying
    # the first login. Thanks Sheelraj
    begin
      response = http.get(uri.path, @@connection_pool[@utility_code.to_sym])
    rescue => e
      raise HTTPInteractorError.new(@utility_code, "/REDACTED/ connection failed with #{e.class} - #{e.to_s}", @operation, uri.to_s)
    end
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection  
      if response.header['location'].present?
        if response.header['location'].include?('maintenance')
          raise HTTPInteractorError.new(@utility_code, "/REDACTED/ Unavailable 503 Error", @operation, uri.to_s)
        else
          response = follow_redirection(response, response.header)
        end
      end
      login_doc = Nokogiri::HTML(response.body)
      csrf_token = login_doc.xpath("//input[@name = '_csrf']/@value").text
      cookie = response.response['set-cookie'].slice(/JSESSIONID=.*;/).chop
      header = @@connection_pool[@utility_code.to_sym].merge({'Cookie' => cookie, 'X-CSRF-TOKEN' => csrf_token})
    else
      # We're getting some other unexpected HTTP response, so let's raise a CSR error
      raise HTTPInteractorError.new(@utility_code, response.code_type.to_s + " " + response.code , @operation, uri.to_s)
    end
    
    uri = URI.parse("#{@base_url}#{LOGIN_URL}")
    http = new_http(uri)
    if Rails.env.alpha?
      data = "j_username=/REDACTED/&j_password=/REDACTED/!"
    else
      data = "j_username=#{/REDACTED/}&j_password=#{/REDACTED/}"
    end
    begin
      response = http.post(uri.path, data, header)
    rescue => e
      raise HTTPInteractorError.new(@utility_code, "Unable to login to /REDACTED/ due to: #{e.class} - #{e.to_s}", @operation, uri.to_s)
    end
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      new_location = response.header['location']
      if new_location
        if new_location.include?('/user/login.do')
           # trying to redirect back to login
          response = follow_redirection(response, header)
          raise HTTPInteractorError.new(@utility_code, response.body.slice(/<.*class="error">[\s\S]*?<.*>/)[0..500], @operation, uri.to_s)
        elsif new_location.include?('maintenance')
          raise HTTPInteractorError.new(@utility_code, "/REDACTED/ Unavailable 503 Error", @operation, uri.to_s)
        end
      end
      cookie = response.response['set-cookie'].slice(/JSESSIONID=.*;/).chop
      header = @@connection_pool[@utility_code.to_sym].merge({'Cookie' => cookie, 'X-CSRF-TOKEN' => csrf_token})
    else
      # We're getting some other unexpected HTTP response, so let's raise a /REDACTED/ error
      raise HTTPInteractorError.new(@utility_code, response.code_type.to_s + " " + response.code , @operation, uri.to_s)
    end
    # Save the header containing the session info for later use
    Rails.logger.debug "Login to #{@utility_code} successful"
    @@connection_pool[@utility_code.to_sym] = header
  end
  
  def new_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"  # enable SSL/TLS
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # suppresses "warning peer certificate won't be verified in this ssl session"
    http
  end
  
  def follow_redirection(response, header)
    if (response.header['location']!=nil)
      uri=URI.parse(response.header['location'])
      attempts = 0
      max_attempts = 5
        until(attempts >= max_attempts)
           attempts+=1
           http=new_http(uri)
           # Net::HTTP in ruby 2.0 no longer returns header as hash when calling Response.header and instead
           # includes all header params in the response iteself. Calling to_hash is what's required to get header
           # in hash format as required by HTTP::Get.new
           header = header.to_hash
           # HTTP::Header.to_hash wraps all values in an array for some reason. Need to recreate hash by replacing
           # arrays with strings
           header = header.inject({}) { |hsh, (k,v)| hsh[k] = v.first; hsh } unless header.values.first.is_a?(String)
           start_time=Time.now
           begin
             response=http.request(Net::HTTP::Get.new(uri.path,header))
           rescue => e
             duration = Time.now - start_time
             raise HTTPInteractorError.new(@utility_code, "Unable to follow /REDACTED/ login redirect due to: #{e.class} - #{e.to_s} Operation took #{duration}s", @operation, uri.to_s)
           end
           break if (response.code=="200" || !response.header['location'])
           uri=URI.parse(response.header['location'])
        end # until
      end # if location ! nil
     
    response
  end
  
  def create_data_string(data)
    final_string = ""
    data.each_with_index do |(key, val), index|
      final_string += "#{key}=#{val}"
      final_string += "&" unless index == data.size-1
    end
    final_string
  end
end
