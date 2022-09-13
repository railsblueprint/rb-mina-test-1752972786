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
