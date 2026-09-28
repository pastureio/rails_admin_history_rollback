module RailsAdmin
  module Config
    module Actions
      class HistoryShow
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :http_methods do
          [:get, :put]
        end

        register_instance_option :controller do
          proc do
            if params.key?(:version_id) || request.put?
              handle_version_request(@object)
            else
              @general = false
              @history = @auditing_adapter&.listing_for_object(@abstract_model, @object, params[:query], params[:sort], params[:sort_reverse], params[:all], params[Kaminari.config.param_name]) || []
              render @action.template_name
            end
          end
        end
      end
    end
  end
end
