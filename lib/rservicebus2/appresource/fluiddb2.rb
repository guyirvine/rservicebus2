# frozen_string_literal: true

require 'fluiddb2'

module RServiceBus2
  # Implementation of an AppResource - FluidDb2
  class AppResourceFluidDb2 < AppResource
    def connect(uri)
      FluidDb2.db(uri)
    end

    # Transaction Semantics
    def begin
      @connection.begin
    end

    # Transaction Semantics
    def commit
      @connection.commit
    end

    # Transaction Semantics
    def rollback
      @connection.rollback
    end
  end
end
