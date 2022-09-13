class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional:    true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  begin
    all.map do |record|
      define_singleton_method(record.name.to_sym) do
        record
      end
    end
  rescue ActiveRecord::StatementInvalid
    Rails.logger.warn "Warning: Roles table missing, not role accessors created "
  end
end
