class AdminRequest
  def self.matches?(request)
    Whitehall.admin_whitelist?(request)
  end
end

Whitehall::Application.routes.draw do
  def redirect(path, options = {prefix: Whitehall.router_prefix})
    super(options[:prefix] + path)
  end

  root to: redirect("/admin/"), constraints: lambda { |request|
    ::Whitehall.admin_hosts.include?(request.host)
  }
  root to: redirect("/")

  match '/browse/*parent_tag/:id', to: 'mainstream_categories#show'

  namespace 'api' do
    resources :detailed_guides, path: 'specialist', only: [:show, :index], defaults: { format: :json } do
      collection do
        get :tags
      end
    end
  end

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: "home#sunset"
    match '/home' => 'home#home'
    match '/feed' => 'home#feed', constraints: { format: :atom }, as: :atom_feed
    match '/tour' => redirect("/tour", prefix: "")

    resources :announcements, only: [:index], path: 'announcements'
    resources :policies, only: [:index, :show] do
      member do
        get :activity
      end
      resources :supporting_pages, path: "supporting-pages", only: [:index, :show]
    end
    resources :news_articles, path: 'news', only: [:show]
    match "/news" => redirect("/announcements")
    resources :publications, only: [:index, :show]
    resources :case_studies, path: 'case-studies', only: [:show, :index]
    resources :speeches, only: [:show]
    resources :statistical_data_sets, path: 'statistical-data-sets', only: [:index, :show]
    match "/speeches" => redirect("/announcements")

    resources :international_priorities, path: "international-priorities", only: [:index, :show]
    resources :consultations, only: [:index, :show] do
      collection do
        get :open
        get :closed
        get :upcoming
      end
    end

    resources :topics, path: "topics", only: [:index, :show]
    resources :organisations, only: [:index, :show] do
      resources :document_series, only: [:index, :show], path: 'series'
      member do
        get :about
        get :consultations
        get :chiefs_of_staff, path: 'chiefs-of-staff'
      end
      resources :corporate_information_pages, only: [:show], path: 'about'
    end

    resources :ministerial_roles, path: 'ministers', only: [:index, :show]
    resources :people, only: [:index, :show]
    resources :countries, path: 'world', only: [:index, :show] do
      member do
        get :about
      end
    end

    resources :policy_teams, path: 'policy-teams', only: [:index, :show]

    match "/search" => "search#index"
    match "/autocomplete" => "search#autocomplete"
    match "/how-government-works" => "home#how-government-works", as: 'how_government_works'

    constraints(AdminRequest) do
      namespace :admin do
        root to: redirect('/admin/editions')

        resource :user, only: [:show, :edit, :update]
        resources :authors, only: [:show]
        resources :organisations do
          resources :document_series
          resources :corporate_information_pages
        end
        resources :policy_teams, except: [:show]
        resources :edition_organisations, only: [:edit, :update]
        resources :edition_countries, only: [:update]
        resources :topics, path: "topics", except: [:show]

        resources :editions, only: [:index] do
          member do
            post :submit, to: 'edition_workflow#submit'
            post :revise
            post :approve_retrospectively, to: 'edition_workflow#approve_retrospectively'
            post :reject, to: 'edition_workflow#reject'
            post :publish, to: 'edition_workflow#publish'
            post :unpublish, to: 'edition_workflow#unpublish'
            post :schedule, to: 'edition_workflow#schedule'
            post :unschedule, to: 'edition_workflow#unschedule'
          end
          resource :featuring, only: [:create, :update, :destroy]
          resources :supporting_pages, path: "supporting-pages", except: [:index]
          resources :editorial_remarks, only: [:new, :create], shallow: true
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
        end

        resources :publications, except: [:index]

        resources :policies, except: [:index]
        resources :international_priorities, path: "international-priorities", except: [:index]
        resources :news_articles, path: 'news', except: [:index]
        resources :consultations, except: [:index]
        resources :speeches, except: [:index]
        resources :statistical_data_sets, path: 'statistical-data-sets', except: [:index]
        resources :detailed_guides, path: "detailed-guides", except: [:index]
        resources :people, except: [:show]
        resources :roles, except: [:show] do
          resources :role_appointments, only: [:new, :create, :edit, :update, :destroy], shallow: true
        end
        resources :countries, only: [:index, :edit, :update]
        resources :case_studies, path: "case-studies", except: [:index]

        match "preview" => "preview#preview", via: :post
      end
    end

    match '/policy-topics' => redirect("/topics")


    match 'site/sha' => 'site#sha'

    match '/placeholder' => 'placeholder#show', as: :placeholder
  end

  VanityRedirector.new(Rails.root.join("app", "data", "vanity-redirects.csv")).each do |from, to|
    match from, to: redirect(to)
    match from.upcase, to: redirect(to)
  end

  get 'healthcheck' => 'healthcheck#check'

  # XXX: we use a blank prefix here because redirect has been
  # overridden further up in the routes
  match '/specialist/:id', constraints: {id: /[A-z0-9\-]+/}, to: redirect("/%{id}", prefix: '')
  # Detailed guidance lives at the root
  match ':id' => 'detailed_guides#show', constraints: {id: /[A-z0-9\-]+/}, as: 'detailed_guide'

  mount TestTrack::Engine => "test" if Rails.env.test?

  match '/government/uploads/*path.:extension' => "placeholder#placeholder_image", constraints: { extension: /(jpe?g|gif|png)/i }
  match '/government/uploads/*path' => redirect("/placeholder"), as: :attachment_placeholder
end
