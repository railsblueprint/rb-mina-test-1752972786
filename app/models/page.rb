class Page < ApplicationRecord
  include PgSearch
  pg_search_scope :search, against: [:title, :url, :body]

  scope :active, -> { where(active: true) }
  scope :sidebar, -> { active.where(show_in_sidebar: true) }
end
