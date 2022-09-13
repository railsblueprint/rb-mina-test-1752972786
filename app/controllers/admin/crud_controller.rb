class Admin::CrudController < Admin::Controller
  respond_to :html, :json

  before_action do
    prepend_crumbs
    breadcrumb index_title, index_url
  end
  before_action :add_search_crumb, except: :index

  before_action only: :index do
    query_parameters = request.query_parameters.except("filter")
    redirect_to index_url if query_parameters.any? && query_parameters.values.all?(&:blank?)
  end

  before_action :load_resource, only: [:show, :edit, :update, :update_row, :destroy]
  before_action :check_permissions

  def load_resource
    @resource = model.find(params[:id])
    breadcrumb @resource.send(title), [:admin, @resource]
  end

  def filter_boolean field
    return unless params[field].present?

    @resources = if params[field] == "nil"
                   @resources.where(field => nil)
                 else
                   @resources.where(field => params[field].to_b)
                 end
  end

  def prepend_crumbs; end

  def add_search_crumb
    breadcrumb "Search results", search_url if search_url && url_for(index_url) != search_url
  end

  def index_url
    [:admin, model.to_s.pluralize.underscore.to_sym]
  end

  def index_title
    model.to_s.pluralize
  end

  def index
    @resources = scope
    filter_resources
    order_resources
    @resources = @resources.page(params[:page]).per(20)
    update_search_url
    add_search_crumb
  end

  def order_resources
    @resources = @resources.order(:created_at).reverse_order
  end

  def filter_resources; end

  def show; end

  def new
    breadcrumb t("actions.new"), ""
    @resource ||= model.new
    render :form
  end

  def create
    @resource = model.create(safe_params)
    if @resource.valid?
      flash[:success] = t("messages.successfully_created")
      redirect_to [:edit, :admin, @resource], status: :see_other
    else
      new
    end
  end

  def edit
    breadcrumb t("actions.edit"), [:edit, :admin, @resource]
    render :form
  end

  def update_row
    @resource.update(safe_params)
    respond_with @resource
  end

  def update
    @resource.update(safe_params)
    respond_to do |format|
      format.json {
        head :ok
      }
      format.html {
        flash[:success] = t("messages.successfully_updated")
        url = params[:back_url].presence || [:edit, :admin, @resource]
        redirect_to url, status: :see_other
      }
    end
  end

  def destroy
    @resource.destroy
    flash[:success] = t("messages.successfully_deleted")
    redirect_to url_for(action: :index), status: :see_other
  end

  def model
    raise "Model not specified"
  end

  def scope
    model.all
  end

  def safe_params
    raise "safe_params not specified"
  end

  def check_permissions
    return if can?(params[:action].to_sym, @resource || model)

    message = if request.method == "GET"
                I18n.t("messages.you_cannot_access_this_page")
              else
                I18n.t("messages.you_cannot_peform_this_action")
              end

    flash[:error] = message
    redirect_back(fallback_location: fallback_url)
  end

  def fallback_url
    return [:admin, @resource] if @resource && can?(:read, @resource)
    return search_url if search_url.present? && can?(:read, model)
    return index_url if can?(:read, model)

    [:admin]
  end

  def update_search_url
    session[search_url_key] = request.url
  end

  def search_url
    session[search_url_key]
  end

  def search_url_key
    :"#{params[:controller]}_search_url"
  end
end
