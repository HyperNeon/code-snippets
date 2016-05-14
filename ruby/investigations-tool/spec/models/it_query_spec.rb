require 'rails_helper'

RSpec.describe ITQuery do

  describe ".get_available_queries" do

    it "returns an ITResponse containing query information" do
      qi_queries = [
          {
              name: "query1",
              description: "test1",
              options: ["option1"],
              classname: "rspec"
          }
      ]
      QueryInterfaceAPIConnection.stubs(:get_queries).returns(qi_queries)
      result = [
        {
          name: "query1",
          method: :submit_query_interface_query,
          async: true,
          description: "test1",
          options: ["option1"],
          additional_info: {
            classname: "rspec",
          }
        },
        {
          name:        "Observatory Search",
          method:      :observatory_search,
          async:       false,
          description: "Return All File Information From The Last Year"
        },
        {
          name:        'ARGH Search',
          method:      :argh_search,
          async:       false,
          description: 'Return all the Report Information for the last month'
        },
        {
          name:        'Query Interface Tool Status',
          method:      :submit_query_interface_query,
          description: 'provide a UUID returned by the query interface tool to retrieve the status of your query',
          options:     ['uuid']
        },
        {
          name:        'Retrieve missing rules',
          method:      :missing_rule_lookup,
          description: 'Retrieve empty_rules, missing_content_rules and incomplete_rules from Scrapi'
        },
        {
          name:        'Bertha Job Details',
          method:      :bertha_job_details,
          description: 'Retrieve details about the last 500 bertha jobs for a client'
        },
        {
          name:        'File Ingest Details',
          method:       :file_ingest_details,
          description: 'Displays the Ingest Details from the past year from the current date'
        },
        {
          name:        'Daily Metrics Details for Billing',
          method:      :daily_billing_reads,
          description: 'Displays the daily metrics for Billing Reads for the past month'
        },
        {
            name:        'Daily Metrics Details for AMI',
            method:      :daily_ami_reads,
            description: 'Displays the daily metrics for AMI Reads for the past month'
        }
      ]
      expected_response = ITResponse.new(result: result)
      expect(ITQuery.get_available_queries).to eq(expected_response)
    end

    it "returns an ITResponse with errors if Query Interface fails" do
      QueryInterfaceAPIConnection.stubs(:get_queries).raises("It Failed")
      expected_response = ITResponse.new(errors: "ERROR - It Failed was received while getting Query Interface Queries")
      expect(ITQuery.get_available_queries).to eq(expected_response)
    end
  end

  describe ".observatory_search" do

    it "returns an ITREsponse of file information" do

      result = [
        {
          name: "file1",
          date: Time.parse("2015-03-02 5:55 PM"),
          size: "1kb",
          linecount: 42
        }
      ]
      ObservatoryAPIConnection.stubs(:get_results).returns(result)

      expected_response = ITResponse.new(result: result)
      expect(ITQuery.observatory_search(query: nil)).to eq(expected_response)
    end

    it "returns and ITResponse with an error if Observatory search fails" do
      ObservatoryAPIConnection.stubs(:get_results).raises("It Failed")
      expected_response = ITResponse.new(errors: "ERROR - Received It Failed while running observatory search")
      expect(ITQuery.observatory_search(query: nil)).to eq(expected_response)
    end
  end

  describe ".ARGH Search" do
    it "returns an ITResponse that contains the report information" do
      result = [{
                    batch_id: 'd6edfe44-7a81-41ed-a5d8-f2895f82dac1',
                    created_at: '2015-04-30T13:19:56Z',
                    deleted_at: nil,
                    eligible_volume: nil,
                    end_time: '2013-01-08T04:06:32Z',
                    flagged: false,
                    id: 2378,
                    job_instance_id: 138,
                    pipeline_id: 0,
                    report_type: 'PRINT',
                    start_time: '2013-01-07T23:27:50Z',
                    updated_at: '2015-04-30T13:27:43Z',
                    utility_id: 26,
                    volume: 14253
                }]
      ArghAPIConnection.stubs(:get_all_reports).returns(result)
      expected_response = ITResponse.new(result: result)
      expect(ITQuery.argh_search({options: {client: nil}})).to eq(expected_response)
    end
  end

  describe ".Missing Rule Lookup" do
    it "returns an ITResponse that contains the report information" do
      missing_rule_result = [{
                    :track_name=>"SCL-Excluding-CPW",
                    :recipient_count=>27114,
                    :control_count=>18422,
                    :rule_type=>"emptyRules",
                    :start_date=>"2011-11-20",
                    :end_date=>"2012-01-21"
                }]

      HttpClient.stubs(:get).returns([])
      ScrapiAPIConnection.stubs(:retrieve_missing_rules).returns(missing_rule_result)
      expected_response = ITResponse.new(result: missing_rule_result)
      expect(ITQuery.missing_rule_lookup({options: {client: 'pge'}})).to eq(expected_response)
    end
  end

  describe ".file ingest information" do
    it 'returns a ITResponse that contains the ingest information' do
      result = [{
                    :name=>"opwr_aepk_full_20151106.txt.pgp",
                    :status=>"SITE_TABLE",
                    :received_on=>"06-11-2015 10:04 UTC",
                    :temporal_type=>"BILLING", :late=>false,
                    :tier=>"production",
                    :file_size_in_bytes=>464307546,
                    :line_count=>1270487,
                    :last_update=>"2015-11-06T18:21:25.000Z",
                    :sub_file_status=>"SITE_TABLE"
                }]

      Speed2ApiConnection.stubs(:get_file_ingest_data).returns(result)
      expected_response = ITResponse.new(result: result)

      expect(ITQuery.file_ingest_details({options: {client: 'test'}})).to eq(expected_response)
    end
  end

  describe ".daily read metrics information for billing" do
    it 'returns a ITResponse that contains the daily read metrics' do
      result = [{
                    :date=>"11-10-2015",
                    :value=>0,
                    :benchmark=>0
                }]

      Speed2ApiConnection.stubs(:get_daily_billing_reads).returns(result)
      expected_response = ITResponse.new(result: result)

      expect(ITQuery.daily_billing_reads({options: {client: 'test'}})).to eq(expected_response)
    end
  end

  describe ".daily read metrics information" do
    it 'returns a ITResponse that contains the dail read metrics for AMI' do
      result = [{
                    :date=>"11-10-2015",
                    :value=>0,
                    :benchmark=>0
                }]

      Speed2ApiConnection.stubs(:get_daily_ami_reads).returns(result)
      expected_response = ITResponse.new(result: result)

      expect(ITQuery.daily_ami_reads({options: {client: 'test'}})).to eq(expected_response)
    end
  end

  describe ".bertha_job_details" do
    it "returns an ITResponse that contains the report information" do
      result = [{
          client: 'test',
          jobName: 'test_job',
          status: 'COMPLETED',
          batchId: 'TEST-1',
          externalId: 'TEST-2',
          pipelineKey: 'TEST-3',
          submitted: '2011-11-20',
          ended: '2011-11-20',
          params: {'param1' => 1},
          summary: {'test' => 2},
          failedStep: nil,
          failMessage: nil,
        }]
      BerthaAPIConnection.stubs(:bertha_query).returns(result)

      expected_response = ITResponse.new(result: result)
      expect(ITQuery.bertha_job_details({options: {client: 'test'}})).to eq(expected_response)
    end
  end

  describe ".submit_query_interface_query" do
    let (:query_interface_fixture) {{method: 'query', options: {uuid: 1}}}

    it "returns an ITResponse with a result" do
      result = {result: "did it"}
      QueryInterfaceAPIConnection.stubs(:get_query_status).returns(result)
      expected_response = ITResponse.new(**result)
      expect(ITQuery.submit_query_interface_query(query_interface_fixture)).to eq(expected_response)
    end

    it "returns an ITResponse with an error if Query Interface fails" do
      QueryInterfaceAPIConnection.stubs(:get_query_status).raises("It Failed")
      expected_response = ITResponse.new(errors: "ERROR - Received It Failed while running Query Interface query")
      expect(ITQuery.submit_query_interface_query(query_interface_fixture)).to eq(expected_response)
    end

    it "calls submit_query if called without a uuid" do
      QueryInterfaceAPIConnection.expects(:submit_query)
      ITQuery.submit_query_interface_query(query: {
                                             "name" => "test",
                                             "additional_info" => {
                                                 "classname" => "rspec"
                                             }
                                         }, options: {})
    end

    it "calls get_query_status if called with a uuid" do
      QueryInterfaceAPIConnection.expects(:get_query_status)
      ITQuery.submit_query_interface_query(query_interface_fixture)
    end
  end

  describe ".get_query_response" do
    it "calls observatory_search with passed params" do
      query = "query"
      options = {uuid: 1}

      ITQuery.expects(:observatory_search).with(query: query, options: options)
      ITQuery.get_query_response(:observatory_search, query, options)
    end

    it "returns an ITResponse with an error if method is not approved" do
      method = :fake_method
      expected_response = ITResponse.new(errors: "ERROR - Method #{method} is not on approved query list")
      expect(ITQuery.get_query_response(method, nil, nil)).to eq(expected_response)
    end
  end
end
