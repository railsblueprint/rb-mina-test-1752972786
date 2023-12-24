FactoryBot.define do
  factory :post do
    title { Faker::Hacker.say_something_smart }

    body {
      rand(10).times.map do
        Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true)
      end.join("<br/>")
    }

    association :user
  end
end
