module RecaptchaHelper
  def recaptcha_data_attributes form, options={}
    {
      controller:                      "recaptcha",
      "turbo-temporary":               true,
      "recaptcha-recaptcha-net-value": options[:recaptcha_net],
      "recaptcha-site-key-v2-value":   AppConfig.recaptcha&.v2&.site_key,
      "recaptcha-site-key-v3-value":   AppConfig.recaptcha&.v3&.site_key,
      "recaptcha-version-value":       options[:version] || form.object.recaptcha_version,
      "recaptcha-action-value":        options[:action] || form.object.recaptcha_action,
      "recaptcha-field-name-value":    form.field_name(:recaptcha_v2_response)
    }
  end

  def recaptcha form, options={}
    form.form_group(:recaptcha) do
      content_tag :div, data: recaptcha_data_attributes(form, options) do
        concat(content_tag(:div, "", "data-recaptcha-target": "holder"))
        concat form.hidden_field(:recaptcha_v3_response, "data-recaptcha-target": "input")
        concat(content_tag(:div, "", class: "is-invalid")) if form.object.errors[:recaptcha].present?
        concat form.errors_on(:recaptcha, hide_attribute_name: true)
      end
    end
  end
end
