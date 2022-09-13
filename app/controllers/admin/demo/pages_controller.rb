class Admin::Demo::PagesController < Admin::Controller
  layout "devise", only: [:register, :login, :error]
end
