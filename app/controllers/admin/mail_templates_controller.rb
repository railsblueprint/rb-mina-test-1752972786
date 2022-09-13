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

  def model
    MailTemplate
  end

  def title
    :alias
  end

  def create
    @resource = MailTemplate.new
    @resource.update safe_params.merge(not_migrated: true)

    if @resource.valid?
      flash[:success] = I18n.t("messages.successfully_created")
      redirect_to [:edit, :admin, @resource], status: :see_other
    else
      breadcrumb t("actions.new"), action: :new
      render "form", status: :unprocessable_entity
    end
  end

  def destroy
    @resource = MailTemplate.find(params[:id])
    @resource.update(deleted_at: Time.now)
    flash[:success] = t("messages.successfully_deleted")
    redirect_to action: :index, status: :see_other
  end

  def preview
    template = MailTemplate.find(params[:id])

    body = template.body

    render html: body.html_safe, layout: "layouts/mail/#{template.layout}"
  end

  def rename_templates
    return if params[:alias] == params[:letter_template][:alias]

    model.where(alias: params[:alias]).update_all(alias: params[:letter_template][:alias])
  end

  private

  def safe_params
    params.require(:mail_template).permit(
      :alias, :subject, :body, :layout
    )
  end
end
