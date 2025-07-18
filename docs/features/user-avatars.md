# User Avatar Feature

The Plus edition includes comprehensive user avatar support with image upload and processing capabilities.

## Overview

Users can upload custom avatar images that are automatically processed and optimized for web display. The system also provides default avatar generation based on user initials.

## Features

- **Image Upload**: Support for common image formats (JPG, PNG, GIF)
- **Automatic Processing**: Images are automatically resized and optimized
- **Default Avatars**: Colorful initials-based avatars for users without uploads
- **Two Avatar Types**:
  - `avatar` - The processed, optimized version for display
  - `avatar_source` - The original uploaded file

## Implementation Details

### Model Configuration

The User model includes Active Storage attachments:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  has_one_attached :avatar_source
  
  # Generate initials for default avatar
  def initials
    full_name.gsub(/[^\p{L} ]/, "").split.tap { |a| break a.size > 1 ? a[0][0] + a[1][0] : a[0][0..1] }
  end
  
  # Consistent color for user's default avatar
  def avatar_color
    (full_name.gsub(/[^a-zA-Z]/, "").to_i(36) % 8) + 1
  end
end
```

### Avatar Display

The system includes a view component for consistent avatar display across the application:

```slim
- if user.avatar.attached?
  = image_tag user.avatar, class: "avatar-image"
- else
  .avatar-placeholder class="avatar-color-#{user.avatar_color}"
    = user.initials
```

### Upload Interface

Users can update their avatar through the profile settings:

1. Navigate to `/profile/edit_avatar`
2. Select an image file
3. Preview the upload
4. Save changes

### Image Processing

When an avatar is uploaded:
1. The original is saved as `avatar_source`
2. A processed version is created as `avatar`
3. The processed version is optimized for web display (typically 200x200)

## Configuration

### Storage

Configure Active Storage in your environment:

```ruby
# config/environments/production.rb
config.active_storage.variant_processor = :image_processing
```

### Allowed Formats

Supported image formats are configured in the upload form:
- JPEG/JPG
- PNG
- GIF
- WEBP

## Security Considerations

- File size limits are enforced (default: 5MB)
- Only image MIME types are accepted
- Files are scanned for malicious content
- Direct upload URLs expire after a short time

## Styling

The avatar system includes CSS classes for different sizes:
- `.avatar-sm` - Small avatars (32x32)
- `.avatar-md` - Medium avatars (64x64)
- `.avatar-lg` - Large avatars (128x128)
- `.avatar-xl` - Extra large avatars (200x200)

## Best Practices

1. Always check if avatar is attached before displaying
2. Provide meaningful alt text for accessibility
3. Use the appropriate avatar size for the context
4. Consider lazy loading for performance
5. Implement fallback for failed image loads