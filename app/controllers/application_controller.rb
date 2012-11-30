class ApplicationController < ActionController::Base
  protect_from_forgery
  # helpers by default included in views, since we need authentication also
  # in our controllers we include the SessionsHelper here
  include SessionsHelper
end
