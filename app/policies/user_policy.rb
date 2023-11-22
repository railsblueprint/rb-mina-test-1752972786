class UserPolicy < ApplicationPolicy
  def impersonate?
    @user&.superadmin?
  end

  def change_password?
    @user == @resource || @user&.superadmin?
  end

  def change_roles?
    @user&.superadmin?
  end
end
