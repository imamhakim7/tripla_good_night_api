module Api
  class RelationshipController < ApplicationController
    include UserRelationshipCacheable

    before_action :set_relationable
    before_action :set_action_type

    def create
      relationship = Relationship.find_or_initialize_by(
        user: @current_user,
        action_type: @action_type,
        relationable: @relationable
      )

      if relationship.persisted?
        render json: relationship, status: :ok
      else
        relationship.save!
        invalidate_relationship_cache_if_needed(@action_type, @current_user, @relationable)
        render json: relationship, status: :created
      end
    end

    def destroy
      relationship = Relationship.find_by(
        user: @current_user,
        action_type: @action_type,
        relationable: @relationable
      )

      if relationship&.destroy
        invalidate_relationship_cache_if_needed(@action_type, @current_user, @relationable)
        render json: relationship, status: :no_content
      else
        render json: { error: "Not found" }, status: :not_found
      end
    end

    private

    def set_relationable
      klass = Relationship::ALLOWED_RELATIONABLE_TYPES[params[:relationable_type].to_s.downcase]
      return render json: { error: "Invalid relationable_type" }, status: :bad_request unless klass

      @relationable = klass.find_by(id: params[:relationable_id])
      render json: { error: "Not found" }, status: :not_found unless @relationable
    end

    def set_action_type
      @action_type = params[:action_type].to_s.downcase
      is_action_type_valid = Relationship::ALLOWED_ACTION_TYPES.include?(@action_type)
      render json: { error: "Invalid action_type" }, status: :bad_request unless is_action_type_valid
    end
  end
end
