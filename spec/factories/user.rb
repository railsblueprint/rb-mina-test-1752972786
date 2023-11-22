FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    confirmed_at { Time.now }

    trait :basic

    trait :moderator do
      roles { [Role.moderator] }
    end

    trait :admin do
      roles { [Role.admin] }
    end

    trait :superadmin do
      roles { [Role.superadmin] }
    end

  end
end
