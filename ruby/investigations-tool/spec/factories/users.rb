FactoryGirl.define do
  factory :user, class: /REDACTED/::User do |f|
    f.first_name         Faker::Name.first_name
    f.last_name          nil
    f.sequence(:email)   { |i| "random.person#{i}@/REDACTED/.com" }
    f.current_sign_in_at Time.now
    f.last_sign_in_at    Time.now
    f.current_sign_in_ip '127.0.0.1'
    f.last_sign_in_ip    '127.0.0.1'
    f.toggl_token        nil
  end
end
