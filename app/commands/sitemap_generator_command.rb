class SitemapGeneratorCommand < BaseCommand
  include Rails.application.routes.url_helpers

  def process
    Rails.logger.info "Starting sitemap generation..."

    configure_sitemap
    generate_sitemap

    Rails.logger.info "Sitemap generated successfully"

    submit_to_search_engines if Rails.env.production?

    Rails.logger.info "Sitemap generation completed"
  end

  private

  def configure_sitemap
    SitemapGenerator::Sitemap.default_host = default_host
    SitemapGenerator::Sitemap.public_path = Rails.public_path
    SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
  end

  def generate_sitemap
    command = self
    SitemapGenerator::Sitemap.create do
      # Static pages
      command.send(:add_static_pages_urls, self)
      command.send(:add_blog_posts_urls, self)
      command.send(:add_pages_urls, self)
    end
  end

  def add_static_pages_urls(sitemap)
    sitemap.add root_path, priority: 1.0, changefreq: "weekly"
    sitemap.add faq_path, priority: 0.7, changefreq: "monthly"
    sitemap.add contacts_path, priority: 0.6, changefreq: "monthly"
    sitemap.add subscribe_index_path, priority: 0.8, changefreq: "monthly"
  end

  def add_blog_posts_urls(sitemap)
    Post.find_each do |post|
      sitemap.add post_path(post),
                  lastmod:    post.updated_at,
                  priority:   0.8,
                  changefreq: "weekly"
    end
  end

  def add_pages_urls(sitemap)
    Page.active.find_each do |page|
      sitemap.add "/#{page.url}",
                  lastmod:    page.updated_at,
                  priority:   0.7,
                  changefreq: "monthly"
    end
  end

  def default_host
    AppConfig.port? ? "http://#{AppConfig.host}:#{AppConfig.port}" : "https://#{AppConfig.host}"
  end

  def submit_to_search_engines
    # Submit to Google
    SitemapGenerator::Sitemap.ping_search_engines
    Rails.logger.info "Sitemap submitted to search engines"
  rescue StandardError => e
    Rails.logger.error "Failed to submit sitemap to search engines: #{e.message}"
  end
end
