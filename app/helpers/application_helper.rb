module ApplicationHelper
  include Pagy::Frontend

  def admin?
    request.original_fullpath.start_with?("/admin")
  end

  def bootstrap_flash_messages
    render "shared/bootstrap_flash_messages"
  end

  def tailwind_flash_messages
    # render 'shared/tailwind_flash_messages'
  end

  def body_class
    "controller-#{params[:controller].tr('/', '-')} action-#{params[:action]}"
  end

  def component(name, *, **, &)
    component = "#{name.to_s.camelize}Component".constantize
    render(component.new(*, **), &)
  end

  def component_to_string(name, *, **, &)
    component = "#{name.to_s.camelize}Component".constantize
    render_to_string(component.new(*, **), &)
  end

  def render_turbo_flash
    render turbo_stream: turbo_stream.replace("flash", component_to_string(:toastr_flash))
  end

  def paginator collection
    raw <<~PAGINATOR
        <div class="paginator">
        <nav class="<%= nav_class %>">
          <ul class="pagination <%= pagination_class %>">
            <li class="page-item disabled">
              <span class="page-link">
                #{page_entries_info collection}
              </span>
            </li>
          </ul>
        </nav>
        #{paginate collection, theme: 'bootstrap-5'}
      </div>
    PAGINATOR
  end
end
