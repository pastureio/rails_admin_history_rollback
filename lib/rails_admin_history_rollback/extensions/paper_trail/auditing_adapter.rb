module RailsAdmin
  module Extensions
    module PaperTrail
      class AuditingAdapter
        def version_for(model, object, version_id)
          return nil unless (version_id.is_a?(String) && version_id.present?) || version_id.is_a?(Integer)

          if object.nil?
            versions_for_model(model).find_by(id: version_id)
          else
            object.public_send(model.model.versions_association_name).find_by(id: version_id)
          end
        end
      end

      class VersionProxy
        def message
          @message = @version.event
        end
        def version_id
          @version.id
        end
      end
    end
  end
end
