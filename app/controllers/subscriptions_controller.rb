class SubscriptionsController < ApplicationController
  before_action :auto_subscribe, only: [:subscribe]

  def index
    @subscriptions = current_user.subscriptions
  end

  def new
    @subscriptions_types = Billing::SubscriptionType.active.all
  end

  def subscribe
    if params[:login].present?
      session["user_return_to"] = url_for(login: nil)
      redirect_to new_user_session_path
      return
    end

    @command = Billing::Subscriptions::CreateWithUserCommand.new(reference: params[:reference])
  end

  def auto_subscribe
    return if current_user.blank?

    Billing::Subscriptions::CreateCommand.call(reference: params[:reference], current_user:) do |command|
      command.on(:ok) do |session|
        @url = session.url
        render :redirect, status: :unprocessable_entity
      end
      command.on(:invalid, :abort) do |errors|
        flash[:error] = errors.full_messages.to_sentence
        redirect_to :index
      end
    end
  end

  def do_subscribe
    Billing::Subscriptions::CreateWithUserCommand.call_for(params, reference: params[:reference]) do |command|
      command.on(:ok) do |session|
        @url = session.url
        render :redirect, status: :unprocessable_entity
      end
      command.on(:invalid, :abort) do |errors|
        @command = command
        flash.now[:error] = {
          message: t(".failed_to_subscribe"),
          details: errors.full_messages
        }
        render :subscribe, status: :unprocessable_entity
      end
    end
  end

  def cancel_subscription
    Billing::Subscriptions::CancelCommand.call(context) do |command|
      command.on(:ok) do
        redirect_to my_subscriptions_path, success: "Subscription cancelled successfully."
      end
      command.on(:invalid, :abort) do |errors|
        @command = command
        flash[:error] = {
          message: t(".failed_to_cancel_subscription"),
          details: errors.full_messages
        }
        redirect_to my_subscriptions_path
      end
    end
  end

  def renew
    Billing::Subscriptions::RenewCommand.call(context) do |command|
      command.on(:ok) do
        redirect_to my_subscriptions_path, success: "Subscription renewed successfully."
      end
      command.on(:invalid, :abort) do |errors|
        @command = command
        flash[:error] = {
          message: t(".failed_to_renew_subscription"),
          details: errors.full_messages
        }
        redirect_to my_subscriptions_path
      end
    end
  end

  def invoices
    @subscription = current_user.subscriptions.find_by(id: params[:id])
    @invoices = Stripe::Invoice.search({ query: "subscription: '#{@subscription.stripe_id}'" })
  end

  def successful
    @plan = Billing::SubscriptionType.find_by(reference: params[:plan])
  end

  def cancel; end

  def context
    {
      id:           params[:id],
      current_user:
    }
  end
end
