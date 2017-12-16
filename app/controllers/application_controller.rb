class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
  #Sessionsに関するヘルパーは誰でも使えるようにする
  include TwitterSessionsHelper
  #Usersに関するヘルパーは(ry
  include UsersHelper
end
