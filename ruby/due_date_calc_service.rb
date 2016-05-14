module DueDateCalcService
  CURRENT_WEEK_THRESHOLD = 0
  NEXT_WEEK_THRESHOLD = 7

  # This method composes a hash whose keys map to days in a week and values map to the respective dates
  #
  # @param threshold [Int] This is how we determine if the values need to populated for current or next week
  # @return [Hash] Mapping that looks like
  #     {:monday=>"2016-05-02", :tuesday=>"2016-05-03", :wednesday=>"2016-05-04", :thursday=>"2016-05-05",
  #      :friday=>"2016-05-06", :saturday=>"2016-05-07", :sunday=>"2016-05-08"}
  def self.compute_weekly_day_to_dates(threshold)
    Hash[
        (0..6).map do |n|
          date = Date.today.beginning_of_week + threshold + n
          # Date has a built in DAYNAMES hash constant, use wday to get the day num zero based for proper retrieval
          day = Date::DAYNAMES[date.wday].downcase.to_sym
          [day, date.strftime] #default strftime is '%Y-%m-%d'
        end
    ]
  end

  def self.next_week_dates
    compute_weekly_day_to_dates(NEXT_WEEK_THRESHOLD)
  end

  def self.this_week_dates
    compute_weekly_day_to_dates(CURRENT_WEEK_THRESHOLD)
  end
end
