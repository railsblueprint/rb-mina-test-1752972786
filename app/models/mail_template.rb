class MailTemplate < ApplicationRecord
  if Rails.env.development?
    default_scope -> { where(deleted_at: nil) }

    scope :unsaved, -> { unscoped.where.not(deleted_at: nil).or(MailTemplate.where(not_migrated: true)) }
  end

  def self.available_layouts
    Dir.entries("#{Rails.root}/app/views/layouts/mail").reject { |f|
      f.start_with?(".")
    }.map(&it.split(".").first)
  end

end
