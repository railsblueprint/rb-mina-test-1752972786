# frozen_string_literal: true

class CreateOauthSettings < ActiveRecord::Migration[8.0]
  def up
    # Create OAuth section
    unless Setting.where(key: "oauth").any?
      Setting.create(
        key:         "oauth",
        type:        "section",
        section:     "root",
        description: "OAuth Social Login Settings"
      )
    end
    
    # Google OAuth2
    if Setting.where(key: "oauth.google.enabled").any?
      Setting.where(key: "oauth.google.enabled").update_all(
        type:        "boolean",
        section:     "oauth",
        description: "Enable Google OAuth2 authentication"
      )
    else
      Setting.create(
        key:         "oauth.google.enabled",
        type:        "boolean",
        section:     "oauth",
        value:       "1",
        description: "Enable Google OAuth2 authentication"
      )
    end
    
    # GitHub OAuth
    if Setting.where(key: "oauth.github.enabled").any?
      Setting.where(key: "oauth.github.enabled").update_all(
        type:        "boolean",
        section:     "oauth",
        description: "Enable GitHub OAuth authentication"
      )
    else
      Setting.create(
        key:         "oauth.github.enabled",
        type:        "boolean",
        section:     "oauth",
        value:       "1",
        description: "Enable GitHub OAuth authentication"
      )
    end
    
    # Facebook OAuth
    if Setting.where(key: "oauth.facebook.enabled").any?
      Setting.where(key: "oauth.facebook.enabled").update_all(
        type:        "boolean",
        section:     "oauth",
        description: "Enable Facebook OAuth authentication"
      )
    else
      Setting.create(
        key:         "oauth.facebook.enabled",
        type:        "boolean",
        section:     "oauth",
        value:       "1",
        description: "Enable Facebook OAuth authentication"
      )
    end
    
    # Twitter OAuth
    if Setting.where(key: "oauth.twitter.enabled").any?
      Setting.where(key: "oauth.twitter.enabled").update_all(
        type:        "boolean",
        section:     "oauth",
        description: "Enable Twitter OAuth authentication"
      )
    else
      Setting.create(
        key:         "oauth.twitter.enabled",
        type:        "boolean",
        section:     "oauth",
        value:       "0",
        description: "Enable Twitter OAuth authentication"
      )
    end
    
    # LinkedIn OAuth
    if Setting.where(key: "oauth.linkedin.enabled").any?
      Setting.where(key: "oauth.linkedin.enabled").update_all(
        type:        "boolean",
        section:     "oauth",
        description: "Enable LinkedIn OAuth authentication"
      )
    else
      Setting.create(
        key:         "oauth.linkedin.enabled",
        type:        "boolean",
        section:     "oauth",
        value:       "0",
        description: "Enable LinkedIn OAuth authentication"
      )
    end
  end
  
  def down
    # Usually we don't remove settings in down migration
  end
end