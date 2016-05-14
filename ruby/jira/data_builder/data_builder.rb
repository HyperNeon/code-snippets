class DataBuilder

  def jira_field_parser(issue, field_list, regex = /.*/)
    value = retrieve_field_values(issue, field_list)
    if value
      # Depending on amount of array nesting in the fields, response can have several nested arrays
      # We only care about each of the individual end values so flatten it all
      # Apply the regex to each value and return only those parts that match
      matches = value.flatten.select{|val| val =~ regex }.map{|val| regex.match(val) }.join(",")
    end
    # Force nil for anything besides actual results
    matches.present? ? matches : nil
  end

  private

  # Returns nested array of all values at end of key list
  def retrieve_field_values(issue, keys)
    # Values can be hashes or arrays and can be nested
    if issue.is_a?(Array)
      # If it's an array, iterate over each element but make a shallow copy of the keys
      # so the recursion can continue once per element
      issue.map do |value|
        key_copy = keys.dup
        retrieve_field_values(value, key_copy)
      end
    else
      # If this element is not an array then we use the next key in the list
      k = keys.shift
      if issue[k]
        # If there's no remaining keys after this then simply return the value at the key
        # Otherwise continue processing the remaining keys on the value at this key
        keys.empty? ? [issue[k]] : retrieve_field_values(issue[k], keys)
      else
        # If there's nothing at this key then or the key doesn't exist return nil
        nil
      end
    end
  end
end