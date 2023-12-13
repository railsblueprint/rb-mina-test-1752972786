class Admin::MailTemplatesController < Admin::CrudController
  # before_action {check_role :superadmin}

  def index
    super
    @unsaved = MailTemplate.unsaved.any? if Rails.env.development?
  end

  def filter_resources
    @resources = @resources.where("alias like :q ", q: "%#{params[:q]}%") if params[:q].present?
  end

  def order_resources
    @resources = @resources.order(:alias)
  end

  def no_show_action? = true

  def name_attribute
    :alias
  end

  def preview
    template = MailTemplate.find(params[:id])

    body = template.body.html_safe # rubocop:disable Rails/OutputSafety

    render html: body, layout: "layouts/mail/#{template.layout}"
  end
end
