module RailsAdmin
  module Config
    module Actions
      class HistoryIndex < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :authorization_key do
          :history
        end

        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          [:get, :put] # NEW / ROLLBACK
        end

        register_instance_option :route_fragment do
          'history'
        end

        register_instance_option :controller do
          proc do
            if params.key?(:version_id) || request.put?
              handle_version_request(nil)
            else
              @general = true
              @history = @auditing_adapter&.listing_for_model(@abstract_model, params[:query], params[:sort], params[:sort_reverse], params[:all], params[Kaminari.config.param_name]) || []
              render @action.template_name
            end
          end
        end

        register_instance_option :template_name do
          :history
        end

        register_instance_option :link_icon do
          'fas fa-book'
        end
      end
    end
  end
end
