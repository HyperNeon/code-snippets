FactoryGirl.define do
  factory :utility do
    sequence(:code) { |n| "demo#{n}" }
  end
end
