module Api
  class RelationshipController < ApplicationController
    before_action :set_relationable
    before_action :set_action_type

    def create
      relationship = Relationship.find_or_initialize_by(
        user: @current_user,
        action_type: @action_type,
        relationable: @relationable
      )

      if relationship.persisted?
        render json: { status: "already_exists" }, status: :ok
      else
        relationship.save!
        render json: { status: "created", action_type: @action_type }, status: :created
      end
    end

    def destroy
      relationship = Relationship.find_by(
        user: @current_user,
        action_type: @action_type,
        relationable: @relationable
      )

      if relationship&.destroy
        render json: { status: "deleted", action_type: @action_type }, status: :ok
      else
        render json: { error: "Not found" }, status: :not_found
      end
    end

    private

    def set_relationable
      klass = params[:relationable_type].classify.safe_constantize
      return render json: { error: "Invalid type" }, status: :bad_request unless klass

      @relationable = klass.find_by(id: params[:relationable_id])
      render json: { error: "Not found" }, status: :not_found unless @relationable
    end

    def set_action_type
      @action_type = params[:action_type].to_s.downcase
    end
  end
end
