class ApplicationController < ActionController::Base
    before_action :set_current_user

    def current_user
      @current_user ||= User.find_or_create_by(ip_address: request.remote_ip)
    end
  
    private
  
    def set_current_user
      @current_user = current_user
    end
end
