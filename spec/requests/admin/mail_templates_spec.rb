require "rails_helper"

RSpec.describe "Admin Mail Templates", type: :request do
  include_examples "admin crud controller", {resource: :mail_templates, model: MailTemplate, prefix: "config"}
  include_examples "admin crud controller empty search", {resource: :mail_templates, model: MailTemplate, prefix: "config"}
end