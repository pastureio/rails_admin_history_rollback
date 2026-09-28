require 'active_support/concern'

module RailsAdminHistoryRollback
  module VersionActions
    extend ActiveSupport::Concern

    included do
      helper_method :history_version_path
    end

    private

    # Serves a version_id request for the collection action (object = nil, model scope)
    # and the member action (object = the route record, record scope). A version outside
    # that scope is a 404 on GET and no rollback on PUT.
    def handle_version_request(object)
      @version = @auditing_adapter.version_for(@abstract_model, object, params[:version_id]) if @auditing_adapter

      if request.get?
        if @version
          render partial: 'version', layout: false
        else
          head :not_found
        end
      elsif request.put?
        if @version.nil?
          flash[:error] = t('admin.history_rollback.version_not_found')
        else
          begin
            if @version.event == "create"
              if object
                @result = object.destroy
              else
                @record = @abstract_model.model.find(@version.item_id)
                @result = @record.destroy
              end
            else
              @record = @version.reify
              @result = @record.save
            end

            if @result
              if @version.event == "create"
                flash[:success] = t('admin.history_rollback.rollback_destroy')
              else
                flash[:success] = t('admin.history_rollback.rollback_success')
              end
            else
              flash[:error] = t('admin.history_rollback.rollback_impossible')
            end
          rescue ActiveRecord::RecordNotFound
            flash[:error] = t('admin.history_rollback.version_not_found')
          rescue ActiveRecord::InvalidForeignKey
            flash[:error] = t('admin.history_rollback.rollback_violates_foreign_key')
          end
        end

        if @result && @version && @version.event == "create"
          redirect_to action: :history_index
        else
          redirect_to action: object ? :history_show : :history_index
        end
      end
    end

    def history_version_path(id)
      if @object
        url_for(only_path: true, action: :history_show, model_name: @abstract_model.to_param, id: @object.id, version_id: id)
      else
        url_for(only_path: true, action: :history_index, model_name: @abstract_model.to_param, version_id: id)
      end
    end
  end
end
