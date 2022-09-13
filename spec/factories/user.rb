FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    confirmed_at { Time.now }

    trait :admin do
      roles { [create(:role, name: "admin")] }
    end

    trait :superadmin do
      roles { [create(:role, name: "superadmin")] }
    end

  end
end
