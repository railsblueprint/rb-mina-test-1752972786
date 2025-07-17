require "rails_helper"

RSpec.describe SitemapGeneratorCommand, type: :command do
  include Rails.application.routes.url_helpers

  let(:command) { described_class.new }
  let(:test_host) { "https://example.com" }

  before do
    # Clean up any existing sitemap files
    FileUtils.rm_rf(Rails.public_path.join("sitemaps"))

    # Set AppConfig for consistent testing
    AppConfig.set(:host, "example.com")
    AppConfig.set(:port, nil) # No port = HTTPS
  end

  after do
    FileUtils.rm_rf(Rails.public_path.join("sitemaps"))
  end

  describe "#process" do
    context "when generating sitemap successfully" do
      let!(:post) { create(:post, title: "Test Post") }
      let!(:active_page) { create(:page, url: "test-page", active: true) }
      let!(:inactive_page) { create(:page, url: "inactive-page", active: false) }

      it "generates sitemap without errors" do
        expect { command.call }.not_to raise_error
      end

      it "succeeds" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates sitemap files" do
        command.call

        expect(Rails.public_path.join("sitemaps", "sitemap.xml.gz")).to exist
      end

      it "includes static pages in sitemap" do
        allow(SitemapGenerator::Sitemap).to receive(:create).and_yield
        allow(command).to receive(:add_static_pages_urls)
        allow(command).to receive(:add_blog_posts_urls)
        allow(command).to receive(:add_pages_urls)

        expect(command).to receive(:add_static_pages_urls)

        command.call
      end

      it "includes blog posts in sitemap" do
        allow(SitemapGenerator::Sitemap).to receive(:create).and_yield
        allow(command).to receive(:add_static_pages_urls)
        allow(command).to receive(:add_blog_posts_urls)
        allow(command).to receive(:add_pages_urls)

        expect(command).to receive(:add_blog_posts_urls)

        command.call
      end

      it "includes active pages in sitemap" do
        allow(SitemapGenerator::Sitemap).to receive(:create).and_yield
        allow(command).to receive(:add_static_pages_urls)
        allow(command).to receive(:add_blog_posts_urls)
        allow(command).to receive(:add_pages_urls)

        expect(command).to receive(:add_pages_urls)

        command.call
      end

      it "configures sitemap with correct settings" do
        expect(SitemapGenerator::Sitemap).to receive(:default_host=)
        expect(SitemapGenerator::Sitemap).to receive(:public_path=).with(Rails.public_path)
        expect(SitemapGenerator::Sitemap).to receive(:sitemaps_path=).with("sitemaps/")

        command.send(:configure_sitemap)
      end

      it "logs successful generation" do
        expect(Rails.logger).to receive(:info).with("Starting sitemap generation...")
        expect(Rails.logger).to receive(:info).with("Sitemap generated successfully")
        expect(Rails.logger).to receive(:info).with("Sitemap generation completed")

        command.call
      end
    end

    context "in production environment" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it "submits to search engines" do
        expect(SitemapGenerator::Sitemap).to receive(:ping_search_engines)
        expect(Rails.logger).to receive(:info).with("Starting sitemap generation...")
        expect(Rails.logger).to receive(:info).with("Sitemap generated successfully")
        expect(Rails.logger).to receive(:info).with("Sitemap submitted to search engines")
        expect(Rails.logger).to receive(:info).with("Sitemap generation completed")

        command.call
      end

      context "when search engine submission fails" do
        before do
          allow(SitemapGenerator::Sitemap).to receive(:ping_search_engines)
            .and_raise(StandardError.new("Connection failed"))
        end

        it "logs error but continues" do
          expect(Rails.logger).to receive(:error)
            .with("Failed to submit sitemap to search engines: Connection failed")

          expect { command.call }.not_to raise_error
        end
      end
    end

    context "in non-production environment" do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it "does not submit to search engines" do
        expect(SitemapGenerator::Sitemap).not_to receive(:ping_search_engines)

        command.call
      end
    end
  end

  describe "#default_host" do
    context "when AppConfig has port" do
      before do
        AppConfig.set(:host, "localhost")
        AppConfig.set(:port, "3000")
      end

      it "returns HTTP URL with port" do
        expect(command.send(:default_host)).to eq("http://localhost:3000")
      end
    end

    context "when AppConfig has no port" do
      before do
        AppConfig.set(:host, "production.com")
        AppConfig.set(:port, nil)
      end

      it "returns HTTPS URL without port" do
        expect(command.send(:default_host)).to eq("https://production.com")
      end
    end

    context "when AppConfig port is empty string" do
      before do
        AppConfig.set(:host, "staging.com")
        AppConfig.set(:port, "")
      end

      it "returns HTTPS URL without port" do
        expect(command.send(:default_host)).to eq("https://staging.com")
      end
    end

    context "when AppConfig port is false" do
      before do
        AppConfig.set(:host, "example.com")
        AppConfig.set(:port, false)
      end

      it "returns HTTPS URL without port" do
        expect(command.send(:default_host)).to eq("https://example.com")
      end
    end
  end

  describe "#add_static_pages_urls" do
    let(:sitemap) { instance_double(SitemapGenerator::LinkSet) }

    it "adds all static pages with correct priorities" do
      expect(sitemap).to receive(:add).with(root_path, priority: 1.0, changefreq: "weekly")
      expect(sitemap).to receive(:add).with(faq_path, priority: 0.7, changefreq: "monthly")
      expect(sitemap).to receive(:add).with(contacts_path, priority: 0.6, changefreq: "monthly")
      expect(sitemap).to receive(:add).with(subscribe_index_path, priority: 0.8, changefreq: "monthly")

      command.send(:add_static_pages_urls, sitemap)
    end
  end

  describe "#add_blog_posts_urls" do
    let(:sitemap) { instance_double(SitemapGenerator::LinkSet) }
    let!(:first_post) { create(:post, title: "First Post") }
    let!(:second_post) { create(:post, title: "Second Post") }

    it "adds all blog posts with correct settings" do
      expect(sitemap).to receive(:add).with(post_path(first_post),
                                            lastmod:    first_post.updated_at,
                                            priority:   0.8,
                                            changefreq: "weekly")
      expect(sitemap).to receive(:add).with(post_path(second_post),
                                            lastmod:    second_post.updated_at,
                                            priority:   0.8,
                                            changefreq: "weekly")

      command.send(:add_blog_posts_urls, sitemap)
    end
  end

  describe "#add_pages_urls" do
    let(:sitemap) { instance_double(SitemapGenerator::LinkSet) }
    let!(:active_page) { create(:page, url: "active-page", active: true) }
    let!(:inactive_page) { create(:page, url: "inactive-page", active: false) }

    it "adds only active pages with correct settings" do
      expect(sitemap).to receive(:add).with("/active-page",
                                            lastmod:    active_page.updated_at,
                                            priority:   0.7,
                                            changefreq: "monthly")
      expect(sitemap).not_to receive(:add).with("/inactive-page", anything)

      command.send(:add_pages_urls, sitemap)
    end
  end
end
