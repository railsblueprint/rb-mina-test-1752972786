module AdminHelper
  def config?
    request.original_fullpath.start_with?("/admin/config")
  end

  def maintenance?
    request.original_fullpath.start_with?("/admin/pg_hero", "/admin/good_job")
  end

  def components?
    request.original_fullpath.start_with?("/admin/demo/components")
  end

  def forms?
    request.original_fullpath.start_with?("/admin/demo/forms")
  end

  def tables?
    request.original_fullpath.start_with?("/admin/demo/tables")
  end

  def charts?
    request.original_fullpath.start_with?("/admin/demo/charts")
  end

  def icons?
    request.original_fullpath.start_with?("/admin/demo/icons")
  end

  def nav_link(link_path, &block)
    link_to link_path, class: "nav-link #{class_names(active: current_page?(link_path))}", &block
  end

  def nav_page_link(link_path, &block)
    link_to link_path, class: "nav-link #{class_names(collapsed: !current_page?(link_path))}", &block
  end
end
