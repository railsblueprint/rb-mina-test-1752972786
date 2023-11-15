namespace :admin do

  root 'dashboard#show'

  authenticate :user, ->(user) { user.has_role?('superadmin') } do
    mount GoodJob::Engine, at: 'good_job'
    mount PgHero::Engine, at: 'pg_hero'
  end

  resources :posts
  resources :pages do
    member do
      patch :toggle_active
      patch :toggle_show_in_sidebar
    end
  end

  resources :users do
    collection do
      get :lookup
    end
    member do
      post :impersonate
    end
  end

  concern :mass_updatable do
    collection do
      post :mass_update
    end
  end

  scope path: "config" do
    resources :mail_templates do
      member do
        get :preview
      end
    end
    resources :settings, :notification_settings, concerns: :mass_updatable
  end

  namespace :design_system do
    get 'colors'
    get 'components/alert'
    get "components/accordion"
    get "components/badges"
    get "components/breadcrumbs"
    get "components/buttons"
    get "components/cards"
    get "components/carousel"
    get "components/list_group"
    get "components/modal"
    get "components/tabs"
    get "components/pagination"
    get "components/progress"
    get "components/spinners"
    get "components/tooltips"
    get 'forms/editors'
    get "forms/elements"
    get "forms/layouts"
    get "forms/validation"
    get 'tables/general'
    get "tables/data"
    get 'charts/chartjs'
    get 'charts/apexcharts'
    get 'charts/echarts'
    get 'icons/bootstrap'
    get 'icons/remix'
    get 'icons/boxicons'
    get 'pages/profile'
    get 'pages/faq'
    get 'pages/contact'
    get 'pages/register'
    get 'pages/login'
    get 'pages/error'
    get 'pages/blank'
  end
end
