module JQGrid
  module ControllerExtensions
    module InstanceMethods

      # call from Controller#index action
      #
      # options
      #   :rows_per_page ==> Integer ==> defaults to 20, number of rows to dispaly in single page
      #   :current_page ==> Integer ==> Defaults to 1.  The page to display
      def jqgrid_index_for model, params, columns, options={}
        current_page = params[:page] ? params[:page].to_i : options.fetch(:current_page, 1)
        rows_per_page = params[:rows] ? params[:rows].to_i : options.fetch(:rows_per_page, 20)
        conditions = {:page=>current_page, :per_page=>rows_per_page}
        conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
  
        if params[:_search] == "true"
          conditions[:conditions] = filter_by_conditions(columns) # TODO: this needs to support .where look
        end
  
        records = model.paginate(conditions)
        total_entries= records.total_entries
  
        respond_with(records) do |format|
          format.json { render :json => records.to_jqgrid_json(columns, current_page, rows_per_page, total_entries)}  
        end
      end

      # call from Controller#post_data action
      #
      # options
      #   :add_ok ==> Boolean ==> default to false.  Set to true to allow user to add records
      #   :delete_ok ==> Boolean ==> default to false.  Set to true to allow user to delete records
      def jqgrid_post_data_for(model, params, columns, options={})
        add_ok = options.fetch(:add_ok, false)
        delete_ok = options.fetch(:delete_ok, false)
    
        error_message = ""
        model_attributes = {}
        columns.each {|c| model_attributes[c] = params[c] if params[c]}
    
        object = nil
    
        case params[:oper]
          when 'add'
            object = model.create(model_attributes) if params["id"] == "_empty" && add_ok
          when 'edit'
            object = model.find(params[:id])
            object.update_attributes(model_attributes)
            record_data = {}
            columns.each {|c| record_data[c] = object.send(c)}
          when 'del'
            model.destroy_all(:id => params[:id].split(",")) if delete_ok
          else
            error_message = 'unknown action'
        end

        if not object.nil? && object.errors.empty?
          render :json => [false, error_message, record_data] 
        else
          object.errors.entries.each do |error|
            message << "<strong>#{model.human_attribute_name(error[0])}</strong> : #{error[1]}<br/>"
          end
          render :json =>[true, error_message, record_data]
        end
      end
    end
  end
end

# Add jqgrid_*_for methods to ActionController::Base
class ActionController::Base
  include JQGrid::ControllerExtensions::InstanceMethods
end


