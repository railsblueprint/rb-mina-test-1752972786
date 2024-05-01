class StripeController < ApplicationController
  skip_forgery_protection
  def webhook
    Stripe::ProcessWebhookCommand.call(**webhook_payload) do |command|
      command.on(:ok) { head :ok }
      command.on(:invalid, :abort) { head :bad_request }
    end
  end

  def webhook_payload
    {
      payload:   request.body.read,
      signature: request.env["HTTP_STRIPE_SIGNATURE"]
    }
  end
end
