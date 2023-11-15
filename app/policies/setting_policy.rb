class SettingPolicy < ApplicationPolicy
  def index?
    @user&.superadmin?
  end

  def new? = index?
  def edit? = index?
  def destroy? = index?
end