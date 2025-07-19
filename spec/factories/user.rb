FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { Faker::Internet.password }
    confirmed_at { Time.zone.now }

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

    trait :with_google_oauth do
      after(:create) do |user|
        create(:user_identity, :google, user: user)
      end
    end

    trait :with_github_oauth do
      after(:create) do |user|
        create(:user_identity, :github, user: user)
      end
    end

    trait :with_facebook_oauth do
      after(:create) do |user|
        create(:user_identity, :facebook, user: user)
      end
    end

    trait :with_all_oauth do
      after(:create) do |user|
        create(:user_identity, :google, user: user)
        create(:user_identity, :github, user: user)
        create(:user_identity, :facebook, user: user)
      end
    end
  end
end
