require 'rails_helper'

RSpec.describe DataBuilder, :type => :service do
  let(:issue) do
    {
      'key' => 'TEST-123',
      'fields' => {
        'summary' => 'TEST: EMAIL HOME_ENERGY',
        'customfield_10051' => [
          { 'value' => 'TEST1' },
          { 'value' => 'TEST2' }
        ],
        'empty_field' => nil
      },
      'nested_array1' => [
        {
          'nested_array2' => [
            {
              'value' => 'TEST-1',
              'customfield_10080' => ['TEST1', 'TEST2']
            },
            {
              'value' => 'TEST2'
            }
          ]
        },
        {
          'nested_array2' => [
            {
              'value' => 'TEST1'
            },
            {
              'value' => 'TEST-2'
            }
          ]
        }
      ]
    }
  end
  let(:data_builder) { DataBuilder.new }

  describe '#jira_field_parser' do

    it 'loops through a supplied array of nested field names and returns the result' do
      expect(data_builder.jira_field_parser(issue, %w(fields summary))).to eq(issue['fields']['summary'])
    end

    it 'returns nil if field is nil' do
      expect(data_builder.jira_field_parser(issue, %w(fields empty_field))).to be_nil
    end

    it 'returns nil if invalid nested field names are provided' do
      expect(data_builder.jira_field_parser(issue, %w(fields wrong broken))).to be_nil
    end

    it 'returns the entire field if no regex is supplied' do
      expect(data_builder.jira_field_parser(issue, %w(key))).to eq(issue['key'])
    end

    it 'returns a comma delimited list of values if a single field is an array' do
      expect(data_builder.jira_field_parser(issue, %w(fields customfield_10051 value))).to eq('TEST1,TEST2')
    end

    it 'returns a comma delimited list of values if nested fields are arrays' do
      expect(data_builder.jira_field_parser(issue, %w(nested_array1 nested_array2 value ))).to eq('TEST-1,TEST2,TEST1,TEST-2')
    end

    it 'returns a comma delimited list of values if the final field is an array of strings' do
      expect(data_builder.jira_field_parser(issue, %w(nested_array1 nested_array2 customfield_10080 ))).to eq('TEST1,TEST2')
    end

    context 'regex is supplied' do
      it 'returns the matching text' do
        expect(data_builder.jira_field_parser(issue, %w(key), /^\w*/)).to eq('TEST')
      end

      it 'returns nil if no matching text is found' do
        expect(data_builder.jira_field_parser(issue, %w(key), /BLAH/)).to be_nil
      end

      it 'returns a comma delimited list of values matching the regex if any field is an array' do
        expect(data_builder.jira_field_parser(issue, %w(fields customfield_10051 value), /TEST2/)).to eq('TEST2')
      end

      it 'returns a comma delimited list of values matching the regex if nested fields are arrays' do
        expect(data_builder.jira_field_parser(issue, %w(nested_array1 nested_array2 value ))).to eq('TEST-1,TEST2,TEST1,TEST-2')
      end
    end
  end
end