module Api
  class RelationshipController < ApplicationController
    before_action :set_relationable
    before_action :set_action_type

    ALLOWED_RELATIONABLE_TYPES = {
      "user" => User
    }

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
        render json: relationship, status: :no_content
      else
        render json: { error: "Not found" }, status: :not_found
      end
    end

    private

    def set_relationable
      klass = ALLOWED_RELATIONABLE_TYPES[params[:relationable_type].to_s.downcase]
      return render json: { error: "Invalid relationable_type" }, status: :bad_request unless klass

      @relationable = klass.find_by(id: params[:relationable_id])
      render json: { error: "Not found" }, status: :not_found unless @relationable
    end

    def set_action_type
      @action_type = params[:action_type].to_s.downcase
    end
  end
end
