RSpec.shared_examples 'admin crud controller' do |options|

  resource_name = options[:resource]
  slug = [options[:prefix],options[:resource]].compact.join("/")
  model = options[:model]
  has_filters = options[:has_filters]
  header_lines = has_filters ? 2 : 1

  let(:initial_count) { model.count }

  let(:factory) { resource_name.to_s.singularize.to_sym }

  let(:admin) { create(:user, :superadmin) }
  let(:moderator) { create(:user, :moderator) }
  let!(:page_size) {  model.default_per_page }

  describe "GET /admin/#{slug}/:id/edit" do
    let!(:resource) { create(factory) }

    before do
      sign_in admin

      get "/admin/#{slug}/#{resource.id}/edit"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_form "/admin/#{slug}/#{resource.id}", :post
    end

    it "renders action buttons" do
      expect(response.body).to have_tag("input", type: "submit", value: "Save")
      expect(response.body).to have_tag("a", seen: "Cancel")
      expect(response.body).to have_tag("a", seen: "Delete")
    end
  end

  describe "PATCH /admin/#{slug}/:id" do
    let!(:resource) { create(factory) }

    let(:params) {
      {
        factory => resource.attributes
      }
    }

    before do
      sign_in admin

      patch "/admin/#{slug}/#{resource.id}", params: params
    end

    # it "redirects to edit page" do
    #   expect(response).to redirect_to("/admin/#{slug}/#{resource.id}/edit")
    #   expect(flash[:success]).to match(/Successfully updated/)
    # end

    # it "updates the post" do
    #   expect(post.reload.title).to eq("new title")
    # end
  end

  describe "GET /admin/#{slug}/new" do
    let!(:post) { create(:post) }

    before do
      sign_in admin

      get "/admin/#{slug}/new"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_form "/admin/#{slug}", :post
    end

    it "renders action buttons" do
      expect(response.body).to have_tag("input", type: "submit", value: "Save")
      expect(response.body).to have_tag("a", seen: "Cancel")
    end
  end

  describe "POST /admin/#{slug}" do
    let!(:resource) { build(factory) }

    let(:params) {
      {
        factory => resource.attributes
      }
    }

    before do
      sign_in admin

      post "/admin/#{slug}", params: params
    end

    # it "renders successfully" do
    #   created_resource = model.first
    #
    #   expect(response).to redirect_to("/admin/#{slug}/#{created_resource&.id}/edit")
    #   expect(flash[:success]).to match(/Successfully created/)
    # end

    # it "creates a new post" do
    #   expect{model.count}.to change.
    # end
  end



  describe "DELETE /admin/#{slug}/:id" do
    let!(:resource) { create(factory) }

    before do
      sign_in admin

      delete "/admin/#{slug}/#{resource.id}"
    end

    it "renders successfully" do
      expect(response).to redirect_to("/admin/#{slug}")
      expect(flash[:notice]).to match(/Successfully deleted/)
    end
  end
end

RSpec.shared_examples 'admin crud controller empty search' do |options|

  resource_name = options[:resource]
  slug = [options[:prefix],options[:resource]].compact.join("/")
  model = options[:model]
  has_filters = options[:has_filters]
  header_lines = has_filters ? 2 : 1

  let(:admin) { create(:user, :admin) }
  describe "GET /admin/#{slug}" do
    before do
      sign_in admin

      get "/admin/#{slug}"
    end

    context "when there are no #{slug}" do
      it "says there are no #{slug}" do
        expect(response.body).to include("No #{resource_name.to_s.gsub("_", " ")} found")
      end

      it "includes a link to create a new #{slug}" do
        expect(response.body).to have_tag("a.btn.btn-primary", seen: "Create")
      end

      it "#{header_lines} header lines" do
        expect(response.body).to have_tag("li.item.item-container", count: header_lines)
      end

      it "renders search form" do
        expect(response.body).to have_form "/admin/#{slug}", :get

      end
    end
  end
end

RSpec.shared_examples 'admin crud controller show resource' do |options|

  resource_name = options[:resource]
  slug = [options[:prefix],options[:resource]].compact.join("/")
  model = options[:model]
  has_filters = options[:has_filters]
  header_lines = has_filters ? 2 : 1

  let(:admin) { create(:user, :admin) }

  describe "GET /admin/#{slug}/:id" do
    let!(:resource) { create(factory) }

    before do
      sign_in admin

      get "/admin/#{slug}/#{resource.id}"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "renders action buttons" do
      expect(response.body).to have_tag("a", seen: "Edit")
      expect(response.body).to have_tag("a", seen: "Delete")
    end
  end
end

RSpec.shared_examples 'admin crud controller paginated index' do |options|
  resource_name = options[:resource]
  slug = [options[:prefix],options[:resource]].compact.join("/")
  model = options[:model]
  has_filters = options[:has_filters]
  header_lines = has_filters ? 2 : 1

  let(:initial_count) { model.count }

  let(:factory) { resource_name.to_s.singularize.to_sym }

  let(:admin) { create(:user, :superadmin) }
  let(:moderator) { create(:user, :moderator) }
  let!(:page_size) {  model.default_per_page }

  describe "GET /admin/#{slug}" do
    before do
      sign_in admin

      get "/admin/#{slug}"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    it "includes a link to create a new #{slug}" do
      expect(response.body).to have_tag("a.btn.btn-primary", seen: "Create")
    end

    context "when user is not logged" do
      before do
        sign_out :user

        get "/admin/#{slug}"
      end

      it "redirects to the login page" do
        expect(response).to redirect_to("/users/login")
        expect(flash[:alert]).to match(/You need to sign in or sign up before continuing./)
      end
    end

    context "when user is not authorized" do
      before do
        sign_in moderator

        get "/admin/#{slug}"
      end

      it "redirects to the home #{slug}" do
        expect(response).to redirect_to("/")
        expect(flash[:alert]).to match(/You cannot access this page/)
      end
    end

    context "when there is less than one page" do
      let!(:resources) { create_list(factory, 10 - initial_count) }

      before do
        sign_in admin

        get "/admin/#{slug}"
      end

      it "renders all" do
        expect(response.body).to include("Displaying <b>all 10</b> #{resource_name.to_s.gsub("_", " ")}")
        expect(response.body).to have_tag('ul', class: "pagination")
        expect(response.body).to have_tag("li.item.item-container", count: 10  + header_lines)
      end

      it "renders action buttons" do
        # expect(response.body).to have_tag("a", seen: "Details", count: 10)
        expect(response.body).to have_tag("a", seen: "Delete", count: 10)
      end
    end

    context "when there is more than one page" do
      let!(:resources) { create_list(factory, page_size + 15 - initial_count) }

      before do
        sign_in admin

        get "/admin/#{slug}"
      end

      it "renders first page" do
        expect(response.body).to include("Displaying #{resource_name.to_s.gsub("_", " ")} <b>1&nbsp;-&nbsp;#{page_size}</b> of <b>#{page_size + 15}</b> in total")
        expect(response.body).to have_tag('ul', class: "pagination")

        expect(response.body).to have_tag("li.item.item-container", count: page_size + header_lines)
      end
    end
  end


end
