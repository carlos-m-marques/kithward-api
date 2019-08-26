require 'active_support/concern'

module Privilegeble
  extend ActiveSupport::Concern

  included do
    before_action :set_entity, only: :resource_permissions
    before_action :set_entity_record, only: :resource_permissions

    rescue_from NoEntityError, with: :entity_error
    rescue_from EntityNotFoundError, with: :entity_error
  end

  def permissions
    entity_privileges = Ability::ENTITIES.map do |entity|
      [
        entity.name.to_s,
        Ability::PERMISSIONS.map { |action| [action, can?(action, @entity)] }.to_h
      ]
    end.to_h

    render json: entity_privileges
  end

  def resource_permissions
    render json: Ability::PERMISSIONS.map { |action| [action, can?(action, @entity_record)] }.to_h
  end

  private

  def permission_params
    params.permit(:entity, :entity_id)
  end

  def set_entity_record
    @entity_record ||= @entity.find_by(id: permission_params.require(:entity_id))

    fail EntityNotFoundError.new(@entity, permission_params.require(:entity_id)) unless @entity_record
  end

  def set_entity
    @entity ||= permission_params.require(:entity).classify.constantize
  rescue NameError => e
    fail NoEntityError.new(e.message.match(/constant\s(.*)/)[1])
  end

  def entity_error(error)
    render json: { errors: [error.message] }, status: :unauthorized
  end

  class NoEntityError < StandardError
    def initialize(entity)
      message = "\sInvalid entity #{entity.classify}\s"

      super(message)
    end
  end

  class EntityNotFoundError < StandardError
    def initialize(entity, entity_id)
      message = "No record for #{entity} with Id: #{entity_id}"
      super(message)
    end
  end
end
