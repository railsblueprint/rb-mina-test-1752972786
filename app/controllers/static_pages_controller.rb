class StaticPagesController < ApplicationController
  def home
    @page = Page.active.find_by(url: "")
    return if @page.blank? # renders default home

    set_meta_from_page
    render :page
  end

  def page
    @page = Page.active.find_by(url: params[:path])
    return render_404 if @page.blank?

    set_meta_from_page
  end

  def subscribe
    @command = Billing::Subscriptions::CreateCommand.new
  end

  def subscribe_submit
    Billing::Subscriptions::CreateCommand.call(subscription_type_id: params[], current_user:) do |command|
      command.on(:ok) do |session|
        @url = session.url
        render status: :unprocessable_entity
      end
      command.on(:error, :abort) do |errors|
        flash[:error] = errors.full_messages.to_sentence
        redirect_to :subscribe
      end
    end

    # pp params[:stripeToken]
  end

  def set_meta_from_page
    set_meta_tags title:       @page.title,
                  seo_title:   @page.seo_title,
                  description: @page.seo_description,
                  keywords:    @page.seo_keywords
  end
end
