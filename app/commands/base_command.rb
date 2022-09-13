class BaseCommand
  class AbortCommand < StandardError
  end

  include Wisper::Publisher
  include Virtus.model

  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :transactional, Boolean, default: true

  def self.skip_transaction!
    attribute :transactional, Boolean, default: false
  end

  def self.delay_for(params, &block)
    call_later(
      params.require(name.underscore).permit(attribute_set.map(&:name)), &block
    )
  end

  def self.call_for(params, &block)
    call(
      params.require(name.underscore).permit(attribute_set.map(&:name)), &block
    )
  end

  def self.call(*args)
    new(*args).tap { |obj|
      yield obj if block_given?
    }.call
  end

  def self.call_later(*args)
    new(*args).tap do |command|
      yield command if block_given?

      return command if command.preflight_nok?

      DelayedCommandJob.perform_later(self, *args)

      command.broadcast_ok
    end
  end

  def self.call_at(delay, *args)
    new(*args).tap do |command|
      yield command if block_given?

      return command if command.preflight_nok?

      DelayedCommandJob.set(delay).perform_later(self, *args)

      command.broadcast_ok
    end
  end

  def call
    if transactional
      ActiveRecord::Base.transaction do
        call_without_transaction
      end
    else
      call_without_transaction
    end
  rescue AbortCommand
    broadcast(:abort, errors)
  end

  def call_without_transaction
    return if preflight_nok?

    process
    broadcast_ok
  end

  def preflight_nok?
    return broadcast_unauthorized unless authorized?
    return broadcast_invalid      unless valid?
    return broadcast_stale        if     stale?

    false
  end

  def broadcast_unauthorized
    broadcast(:unauthorized)
  end

  def broadcast_invalid
    broadcast(:invalid, errors)
  end

  def broadcast_stale
    broadcast(:stale)
  end

  def abort_command
    raise AbortCommand
  end

  def broadcast_ok
    broadcast(:ok)
  end

  def authorized?
    true
  end

  def stale?
    false
  end

  def persisted?
    false
  end

  def process
    raise "Interface not implemented"
  end
end
