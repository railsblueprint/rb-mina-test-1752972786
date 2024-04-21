module Users
  class UpdateAvatarCommand < Crud::UpdateCommand
    # attribute :avatar, Types::Nominal(ActiveStorage::Attached::One) | Types::String
    attribute :avatar_cropped, Types::String
    attribute :avatar_source, Types::Nominal(ActiveStorage::Attached::One)
    attribute :avatar_settings, Types::Hash | Types::String
    attribute :remove_avatar, Types::Bool | Types::String

    def resource_attributes
      {
        ** settings,
        ** avatar,
        ** avatar_source_attributes
      }
    end

    def settings
      return {} if remove_avatar.to_b

      { avatar_settings: avatar_settings || "{}" }
    end

    def avatar_source_attributes
      return { avatar_source: nil } if remove_avatar.to_b
      return {} if avatar_source.nil?

      { avatar_source: }
    end

    def avatar
      return { avatar: nil } if remove_avatar.to_b
      return {} if avatar_cropped.blank?

      decoded_data = Base64.decode64(avatar_cropped.split(",")[1])
      content_type = avatar_cropped.split(";")[0].split(":")[1]

      {
        avatar: {
          io:           StringIO.new(decoded_data),
          content_type:,
          filename:     "avatar"
        }
      }
    end
  end
end
