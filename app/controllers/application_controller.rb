class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #Sessionsに関するヘルパーは誰でも使えるようにする
  include TwitterSessionsHelper
  #Questsに関するヘルパーは(ry
  include QuestsHelper
  include UsersHelper
end
