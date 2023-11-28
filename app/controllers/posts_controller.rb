class PostsController < ApplicationController
  include CableReady::Broadcaster

  before_action :set_post, only: [:show, :edit, :update, :destroy]

  before_action :turbo_frame_request_variant
  # authorize_resource

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def index
    scope = Post.all.includes(:user).with_all_rich_text
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.order(created_at: :desc)

    @pagy, @posts = pagy(scope, items: 5)
  end

  def show; end

  def new
    @post = Post.new
  end

  def edit; end

  # rubocop:disable Metrics/AbcSize
  # TODO: how i can fix it?
  def create
    @post = Post.new(post_params.merge(user: current_user))

    respond_to do |format|
      if @post.save

        cable_ready[BlogChannel].morph(
          selector: "#posts",
          position: "afterbegin",
          html:     render_to_string(partial: "post", locals: { post: @post })
        ).broadcast_to("blog")

        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        cable_ready[PostChannel].morph(
          selector: "#{dom_id(@post)}_body",
          html:     render_to_string(partial: "post_body", locals: { post: @post })
        ).broadcast_to(@post)

        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.friendly.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :body)
  end
end
