class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout "zap_site"
  protect_from_forgery with: :exception

  protected
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ZAP_USERNAME && password == ZAP_PASSWORD
    end
  end
end
