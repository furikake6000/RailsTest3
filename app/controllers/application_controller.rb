class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #Sessionsに関するヘルパーは誰でも使えるようにする
  include TwitterSessionsHelper
end
