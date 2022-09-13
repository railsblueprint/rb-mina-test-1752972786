module MailHelper
  def mail_template_layouts
    files = Dir.entries("#{Rails.root}/app/views/layouts/mail").reject { |f|
      f.start_with?(".")
    }.map(&it.split(".").first)
    files.map { |f| [t("mail_templates.names.#{f}"), f] }.sort
  end
end
