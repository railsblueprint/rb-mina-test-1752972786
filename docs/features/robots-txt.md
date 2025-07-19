# Environment-Specific robots.txt Management

The Plus edition includes environment-specific robots.txt serving to control search engine crawling based on the deployment environment.

## Overview

Different environments require different crawling rules:
- **Staging**: Block all crawlers to prevent test content from being indexed
- **Production**: Allow crawlers but restrict admin areas
- **Development**: Not served (uses Rails default)

## Implementation

### Static Files

The system uses static files served directly by nginx for optimal performance:

```
public/
├── robots-staging.txt      # Blocks all crawlers
└── robots-production.txt   # Allows crawlers with restrictions
```

### Staging Configuration

`public/robots-staging.txt`:
```
# Staging environment - prevent all crawling
User-agent: *
Disallow: /
```

### Production Configuration

`public/robots-production.txt`:
```
# Production environment - allow crawling except admin areas
User-agent: *
Disallow: /admin/
Disallow: /sidekiq/
Crawl-delay: 1

# Sitemap location (Pro edition feature)
Sitemap: https://yourdomain.com/sitemap.xml.gz
```

### Nginx Configuration

The nginx configuration template automatically serves the correct file:

```nginx
location = /robots.txt {
  # Serve environment-specific robots.txt
  if ($rails_env = "staging") {
    rewrite ^/robots.txt$ /robots-staging.txt last;
  }
  if ($rails_env = "production") {
    rewrite ^/robots.txt$ /robots-production.txt last;
  }
  
  # Cache for 24 hours
  expires 24h;
  add_header Cache-Control "public, immutable";
}
```

## Deployment

### Mina Integration

The robots.txt files are automatically deployed with your application:

```ruby
# config/deploy.rb
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    
    on :launch do
      # Files in public/ are automatically available
      # Nginx will serve the appropriate robots.txt
    end
  end
end
```

### Testing Deployment

After deployment, verify the correct file is served:

```bash
# Test staging
curl -I https://staging.yourdomain.com/robots.txt

# Test production  
curl https://yourdomain.com/robots.txt
```

## Customization

### Adding Custom Rules

To add environment-specific rules:

1. Edit the appropriate file:
   - `public/robots-staging.txt` for staging
   - `public/robots-production.txt` for production

2. Common customizations:
   ```
   # Block specific bots
   User-agent: BadBot
   Disallow: /
   
   # Protect sensitive paths
   User-agent: *
   Disallow: /api/
   Disallow: /internal/
   
   # Set crawl rate
   Crawl-delay: 2
   ```

3. Deploy the changes

### Adding More Environments

To add a new environment (e.g., demo):

1. Create the file:
   ```bash
   echo "User-agent: *\nDisallow: /" > public/robots-demo.txt
   ```

2. Update nginx template:
   ```nginx
   if ($rails_env = "demo") {
     rewrite ^/robots.txt$ /robots-demo.txt last;
   }
   ```

3. Redeploy with nginx configuration update

## Performance Benefits

Serving robots.txt via nginx provides:
- No Rails processing overhead
- Direct file serving from disk
- Automatic HTTP caching headers
- Reduced server load
- Faster response times

## Monitoring

### Access Logs

Monitor robot activity in nginx logs:

```bash
# See all robots.txt requests
grep "robots.txt" /var/log/nginx/access.log

# See unique user agents
grep "robots.txt" /var/log/nginx/access.log | awk -F'"' '{print $6}' | sort -u
```

### Common Crawlers

Monitor for these common user agents:
- Googlebot
- Bingbot  
- Slurp (Yahoo)
- DuckDuckBot
- facebookexternalhit
- Twitterbot

## Best Practices

1. **Test Before Deploy**: Always test robots.txt changes in staging first
2. **Monitor Impact**: Watch search console after changes
3. **Be Specific**: Use specific paths rather than wildcards where possible
4. **Include Sitemap**: Reference your sitemap in production (Pro edition)
5. **Regular Review**: Periodically review and update rules

## Troubleshooting

### File Not Found

If robots.txt returns 404:
1. Check the files exist in `public/`
2. Verify nginx configuration is correct
3. Ensure nginx was reloaded after configuration change

### Wrong Environment File

If wrong file is served:
1. Check `$rails_env` in nginx: `echo $rails_env`
2. Verify mina deployment environment
3. Check nginx error logs

### Changes Not Reflected

If changes don't appear:
1. Clear nginx cache: `nginx -s reload`
2. Check browser cache (use curl for testing)
3. Verify deployment completed successfully

## SEO Considerations

### Staging Protection

The staging robots.txt prevents:
- Duplicate content penalties
- Test content in search results  
- Development URLs being indexed
- Customer confusion from finding staging site

### Production Optimization

The production configuration:
- Allows main content indexing
- Protects admin interfaces
- Manages crawl rate
- References sitemap for better indexing