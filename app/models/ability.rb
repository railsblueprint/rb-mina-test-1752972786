# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def initialize(user)
    # non-authorized user can do nothing

    can :read, Post

    return unless user

    can :manage, :all if user.has_role? :superadmin

    can :create, Post

    can :update, Post, user: user

    can :manage, Post if user.has_role? :moderator

    # can :manage, :admin_dashboard
    can :manage, User if user.has_role? :admin
    cannot :become, User unless user.has_role? :superadmin

    can :manage, MailTemplate if user.has_role? :admin
    can :manage, Page  if user.has_role? :admin
    can :manage, Post  if user.has_role? :admin

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
