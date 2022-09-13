# rubocop:disable Metrics/ModuleLength
# TODO: split into files
module FormsHelper
  def inside_layout(parent_layout, &block)
    view_flow.set :layout, capture(&block)
    render template: "layouts/#{parent_layout}"
  end

  FLASH_MAP = {
    notice:  "alert-info",
    success: "alert-success",
    error:   "alert-danger",
    alert:   "alwer-warning"
  }.freeze

  def flash_bootstrap
    raw flash.map { |key, value|
      "<div class='alert alert-dismissible #{FLASH_MAP[key]}'  role='alert'>
       #{value}
      <button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='#{t('actions.close')}'></button>
      </div>"
    }.join
  end

  def modal_template
    raw '<div id="modal-window" class="modal fade" tabindex="-1">
          <div class="modal-dialog modal-lg">
            <div id="modal-window-content" class="modal-content">
        </div></div></div>'
  end

  # Bootstrap icon helper
  def bi icon
    raw "<i class='bi bi-#{icon}'></i>"
  end

  # Bootstrap icon helper - using svg format
  def bi_svg icon
    raw "<svg class=\"bi bi-#{icon}\" width=\"32\" height=\"32\" viewBox=\"0 0 20 20\" " \
        "fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\">"
  end

  # Glyphicons icon helpers
  def gi icon
    raw "<span class='glyphicon glyphicon-#{icon}'></span>"
  end

  # Fontawsome icon helpers
  def fa icon
    raw "<i class='fa fa-#{icon}'></i>"
  end

  def fas icon
    raw "<i class='fas fa-#{icon}'></i>"
  end

  def far icon
    raw "<i class='far fa-#{icon}'></i>"
  end

  def fal icon
    raw "<i class='fal fa-#{icon}'></i>"
  end

  def data_filter fields
    content_for :scripts do
      raw fields.map { |c|
        "<div class='filter-data' data-field='#{c}' data-url='#{url_for(params.permit(fields + [:q, :filter]).merge(
                                                                          c => nil, :page => nil, :filter => true
                                                                        ))}'></div>"
      }.join("\n")
    end
  end

  def copy_field_button
    content_tag "button",
                class:             "btn btn-outline-secondary",
                "data-controller": "field-clipboard",
                "data-action":     "field-clipboard#click",
                title:             I18n.t("actions.copy_to_clipboard"),
                "data-success":    I18n.t("messages.copied_successfully"),
                "data-failure":    I18n.t("messages.failed_to_copy") do
      bi "clipboard"
    end
  end

  def link_field_button options={}
    link_to "#", class: "btn btn-outline-secondary",
            title: I18n.t("actions.open_link_in_new_tab"), "data-url-prefix": options[:url_prefix],
            "data-bs-toggle": "tooltip",
            "data-controller": "field-url",
            "data-local": options[:local],
            target: "_blank" do
      bi "link-45deg"
    end
  end

  def search_form fields=[]
    hidden = fields.map { |field|
      hidden_field_tag(field, params[field], id: nil)
    }.join("\n")
    raw <<~FORM
      <form class="form" method="get">
        <div class="input-group">
          <div class="input-group-text">
            <i class="i bi bi-search"></i>
          </div>
          #{hidden}
          <input autocomplete="off" class="form-control" name="q" type="search" value="#{params[:q]}">
          <input class="btn btn-outline-secondary" type="submit" value="Search">
        </div>
      </form>
      #{data_filter(fields)}
    FORM
  end

  def filter_by_supplier_id
    select_tag :supplier_id,
               options_for_select(
                 [["Any", nil]] + Supplier.all.map { |r| [r.alias, r.id] },
                 params[:supplier_id]
               ),
               class: "form-control form-control-sm"
  end

  def filter_by name, options, settings={}
    settings.reverse_merge!(class: "form-control form-control-sm select2")

    select_tag name,
               options_for_select(options, params[name]),
               settings
  end

  def filter_by_binary name, options=[["Any", nil], ["True", true], ["False", false], %w[Unknown nil]]
    filter_by name, options
  end

  def filter_by_user(options={})
    selected = options.delete(:selected)
    default_option = if selected
                       [[I18n.t("search.any"), nil],
                        [selected.full_name, selected.id]]
                     else
                       [[I18n.t("search.any"), nil]]
                     end

    filter_by :user_id,
              default_option,
              data: {
                controller: "admin--user-select",
                empty:      I18n.t("search.any")
              }
  end

  def filter_by_role
    filter_by :role,
              [[I18n.t("search.any"), nil], * Role.all.map { |r| [r.name, r.name] }]
  end

  def filter_by_stock
    filter_by :stock,
              [["Any", nil], ["In stock", true], ["Out of stock", false], %w[Uknown nil]]
  end

  def filter_by_supplier_state
    filter_by :state, [["Any", nil]] + Supplier.state_options
  end

  def filter_by_active
    filter_by_binary :active
  end

  def filter_by_liked
    filter_by_binary :liked
  end

  def filter_by_crawled
    filter_by_binary :crawled
  end

  def filter_by_blocked
    filter_by_binary :blocked
  end

  def filter_by_in_stock
    filter_by_binary :in_stock
  end

  # rubocop:disable Metrics/MethodLength
  # TODO: convert to a constant
  def bool_icons
    @_bool_icons ||= {
      nil      => {
        true  => bi("check-lg"),
        false => bi("x-lg")
      },
      :star    => {
        true  => fas("star"),
        false => far("star")
      },
      :heart   => {
        true  => fas("heart"),
        false => far("heart")
      },
      :dislike => {
        true  => fas("thumbs-down"),
        false => fal("thumbs-down")
      },
      :eye     => {
        true  => fas("eye"),
        false => far("eye text-secondary")
      },
      :acorn   => {
        true  => fas("acorn text-success"),
        false => far("acorn text-danger"),
        nil   => fas("acorn text-secondary")
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def toggle_bool resource, field, options={}
    link_to url_for(action: "toggle_#{field}", id: resource.id), data: { turbo_method: :patch } do
      toggle_bool_icon resource, field, options
    end
  end

  def toggle_bool_icon resource, field, options={}
    icon = (resource.respond_to?("#{field}_icon") && resource.send("#{field}_icon")) || options[:icon]
    content_tag :"turbo-frame", id: "#{resource.id}_#{field}" do
      icons = bool_icons[icon] || bool_icons[nil]

      bool_icon(icons, resource.send(field))
    end
  end

  def bool_icon(icons, value)
    if value.nil? && icons[nil].present?
      icons[nil]
    else
      icons[value.to_b]
    end
  end

  def clipboardable(text=nil, &block)
    text ||= capture(&block) if block

    return unless text.present?

    content_tag(:span) do
      content_tag(:span, text, class: "clipboard_data") +
      link_to(nil, class: "copy_to_clipboard", role: "button", title: "Copy to clipboard") do
        fa("copy")
      end
    end
  end

  def delete_button(resource)
    return unless can? :destroy, resource

    link_to [:admin, resource],
            data:  { turbo_method: :delete,
                     confirm:      "Are you sure you want to delete this #{resource.class.name}?" },
            class: "btn btn-danger btn-sm card-link" do
      "#{fa('trash')} Delete"
    end
  end

  def edit_button(resource, options={})
    return unless can? :edit, resource

    link_to [:edit, :admin, resource], options.merge(class: "btn btn-primary btn-sm card-link") do
      "#{fa('edit')} Edit"
    end
  end

  def percent value
    return "-" unless value

    "%d %%" % (value * 100)
  end

  def price value
    return "-" unless value

    "%.2f" % value
  end
end
# rubocop:enable Metrics/ModuleLength
