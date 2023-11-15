FactoryBot.define do
  factory :mail_template do
    self.alias { Faker::Hacker.say_something_smart.underscore }
    subject { Faker::Hacker.say_something_smart }
    layout { MailTemplate.available_layouts.sample }
    body {
      rand(10).times.map do
        Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true)
      end.join("<br/>")
    }

  end
end
