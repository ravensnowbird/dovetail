class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_payment_method

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name

    devise_parameter_sanitizer.for(:account_update) << :first_name
    devise_parameter_sanitizer.for(:account_update) << :last_name
  end

  def check_payment_method

    return if self.controller_name == "payment_methods" && self.action_name == "new"

    if user_signed_in?
      unless current_user.trialing?
        if current_user.payment_methods.count == 0
          # Trial has expired, need payment method on file.  
          # Will display a nag warning in layout
          @need_payment_method = true
        end
      end
    end
  end

  # Call from any controllers in spaces or nested underneath
  def check_space_payment_method
    if user_signed_in?
      unless current_user.trialing?
        if @space && (@space.payment_method.nil? || @space.stripe_subscription_id.blank?)
          flash[:notice] = "Your trial has ended, please select a payment method." 
          redirect_to edit_space_path(@space)
        end
      end
    end
  end

end
