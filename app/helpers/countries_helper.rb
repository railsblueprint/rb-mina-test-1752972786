module CountriesHelper
  def options_for_country
    ISO3166::Country.pluck(:iso_short_name, :alpha2).sort_by(&:first)
  end
end
