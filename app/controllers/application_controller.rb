class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  #rescue_from Exception, with: :render_500

  protect_from_forgery with: :exception
  include ApplicationHelper
  #Sessionsに関するヘルパーは誰でも使えるようにする
  include TwitterSessionsHelper
  #Usersに関するヘルパーは(ry
  include UsersHelper

  def render_404
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def render_500
    render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
  end
end
