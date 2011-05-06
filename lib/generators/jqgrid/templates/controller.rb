class <%= class_name.pluralize %>Controller < ApplicationController
	respond_to :html,:json
  
	protect_from_forgery :except => [:post_data]
  
	# Don't forget to edit routes if you're using RESTful routing
	# 
	#resources :<%=plural_name%>,:only => [:index] do
	#	collection do
	#	  post "post_data"
	#	end
	# end

	GRID_COLUMNS = [<%= columns.map {|x| ":#{x}"}.join(', ') %>]
	
	def post_data
		jqgrid_post_data_for <%= class_name %>, params, GRID_COLUMNS
	end
	
	def index
		jqgrid_index_for <%= class_name %>, params, GRID_COLUMNS
	end

end
