FactoryBot.define do
  factory :page do
    title { Faker::Hacker.say_something_smart.split(" ")[0..2].join(" ")}

    body {
      "<h1>#{title}</h1>" + rand(30).times.map do
        Faker::Lorem.paragraph(sentence_count: rand(30), supplemental: true)
      end.join("<br/>")
    }

    url { title.parameterize }
    seo_title { title }
    seo_keywords { title.gsub(" ", ", ") }
    seo_description { Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true) }
    icon { ["app", "at", "award", "basket", "battery", "bookmark", "chat-left-text", "cloud", "cpu", "envelope"].sample }
    show_in_sidebar { rand(10) == 0  }
    active { true }

  end
end
