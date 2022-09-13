class StaticPagesController < ApplicationController
  def home
    @page = Page.active.find_by(url: "")
    return unless @page.present?

    set_meta_from_page
    render :page
  end

  def page
    @page = Page.active.find_by(url: params[:path])
    return render_404 unless @page.present?

    set_meta_from_page
  end

  def set_meta_from_page
    set_meta_tags title:       @page.title,
                  seo_title:   @page.seo_title,
                  description: @page.seo_description,
                  keywords:    @page.seo_keywords
  end
end
