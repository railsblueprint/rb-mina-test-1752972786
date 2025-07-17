namespace :sitemap do
  desc "Generate XML sitemap"
  task generate: :environment do
    puts "Generating sitemap..."

    SitemapGeneratorCommand.call do |command|
      command.on(:ok) do
        puts "✅ Sitemap generated successfully"
      end

      command.on(:error) do |error|
        puts "❌ Sitemap generation failed: #{error.message}"
        exit 1
      end
    end
  end

  desc "Generate sitemap and submit to search engines"
  task generate_and_submit: :environment do
    puts "Generating sitemap and submitting to search engines..."

    SitemapGeneratorCommand.call do |command|
      command.on(:ok) do
        puts "✅ Sitemap generated successfully"

        if Rails.env.production?
          puts "🔍 Submitting to search engines..."
          SitemapGenerator::Sitemap.ping_search_engines
          puts "✅ Submitted to search engines"
        else
          puts "ℹ️  Skipping search engine submission in #{Rails.env} environment"
        end
      end

      command.on(:error) do |error|
        puts "❌ Sitemap generation failed: #{error.message}"
        exit 1
      end
    end
  end

  desc "Enqueue sitemap generation job"
  task enqueue: :environment do
    puts "Enqueueing sitemap generation job..."

    SitemapGeneratorCommand.call_later
    puts "✅ Job enqueued"
  end
end
