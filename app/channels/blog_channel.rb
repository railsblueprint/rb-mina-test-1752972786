class BlogChannel < ApplicationCable::Channel
  def subscribed
    stream_from "blog"
  end
end
