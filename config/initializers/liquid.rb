require "i18n_tag.rb"

Liquid::Template.register_tag("t", I18nTag)
Liquid::Template.register_tag("translate", I18nTag)
