# encoding: UTF-8
class ApplicationController < ActionController::Base
	# Includes
	include ActionView::Helpers::TagHelper

  	# Prevent CSRF attacks by raising an exception.
  	# For APIs, you may want to use :null_session instead.
  	protect_from_forgery with: :exception

  	# Helper methods
  	helper_method :displayErrors
  	helper_method :flashDisplay
  	helper_method :currentUser
  	helper_method :authUser
  	helper_method :render404

  	#############################
  	### Helper Implementation ###
  	#############################

  	def displayErrors(object)
    	if object.errors.messages == nil
    		return
    	end
    	if flash[:alert] == nil
    		flash[:alert] = ""
    	end
    	object.errors.messages.each do |name, errors|
    		error = name.to_s.titleize + ": "
    		messages = ""
    		errors.each do |message|
    			if messages.length != 0
    				messages += ", "
    			end
    			messages += message
    		end
    		flash[:alert] += "<br>" + error + messages
    	end
    end # displayErrors

	def flashDisplay
  		response = ""
  		flash.each do |name, msg|
  		    response = response + content_tag(:div, msg.html_safe, :id => "flash_#{name}")
  		end
  		flash.discard
  		response
  	end # flashDisplay

  	def currentUser
      	@currentUser = nil
      	if cookies[:loginAuthToken] == nil
      	  	return nil
  		end
		@currentUser = User.find_by loginAuthToken: cookies[:loginAuthToken]
  	end # currentUser

	def authUser
		if currentUser == nil
			render404
		end
	end # authUser

	def render404
		raise ActionController::RoutingError.new('Not Found')
	end # render404

end
