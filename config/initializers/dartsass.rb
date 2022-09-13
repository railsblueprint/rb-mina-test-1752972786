Rails.application.config.dartsass.builds = {
  "admin.scss"      => "admin.css",
  "frontend.scss"  => "frontend.css"
}

Rails.application.config.dartsass.build_options << " --quiet-deps"