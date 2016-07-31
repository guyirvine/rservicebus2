require 'fluiddb2'

module RServiceBus2
  # Implementation of an AppResource - FluidDb2
  class AppResourceFluidDb2 < AppResource
    def connect(uri)
      FluidDb2.Db(uri)
    end

    # Transaction Semantics
    def Begin
      @connection.begin
    end

    # Transaction Semantics
    def Commit
      @connection.commit
    end

    # Transaction Semantics
    def Rollback
      @connection.rollback
    end
  end
end
