require 'FluidDb/Db'
module RServiceBus
  # Implementation of an AppResource - FluidDb
  class AppResourceFluidDb < AppResource
    def connect(uri)
      FluidDb::Db(uri)
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
