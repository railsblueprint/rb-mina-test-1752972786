class CreateSettings1704842553 < ActiveRecord::Migration[7.1]
  def up
    if Setting.where("key": "recaptcha.v3.minimum_score").any?
      Setting.where("key": "recaptcha.v3.minimum_score").update_all(
        type:        "string",
        section:     "ui",
        description: "Minimum score for invisible recaptcha",
      )
    else
      Setting.create(
        "key":       "recaptcha.v3.minimum_score",
        type:        "string",
        section:     "ui",
        value:       "0.5",
        description: "Minimum score for invisible recaptcha",
      )
    end
    if Setting.where("key": "recaptcha.show.on_contacts").any?
      Setting.where("key": "recaptcha.show.on_contacts").update_all(
        type:        "boolean",
        section:     "ui",
        description: "Show recaptcha on contacts form",
      )
    else
      Setting.create(
        "key":       "recaptcha.show.on_contacts",
        type:        "boolean",
        section:     "ui",
        value:       "1",
        description: "Show recaptcha on contacts form",
      )
    end
    if Setting.where("key": "recaptcha.show.on_registration").any?
      Setting.where("key": "recaptcha.show.on_registration").update_all(
        type:        "boolean",
        section:     "ui",
        description: "Show captcha on registration page",
      )
    else
      Setting.create(
        "key":       "recaptcha.show.on_registration",
        type:        "boolean",
        section:     "ui",
        value:       "1",
        description: "Show captcha on registration page",
      )
    end
  end

  def down
  end
end
