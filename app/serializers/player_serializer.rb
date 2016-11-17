class PlayerSerializer < ActiveModel::Serializer
  attributes :id,
             :nickname,
             :name,
             :portrait_url

  def portrait_url
    if object.profile_picture?
      object.profile_picture.url
    else
      "/avatars/default.png"
    end
  end
end
