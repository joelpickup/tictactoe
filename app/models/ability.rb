class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.valid?
      can :manage, :all
    end
  end
end