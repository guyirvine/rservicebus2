require 'FluidDb/Db'
module RServiceBus2
  # Implementation of an AppResource - FluidDb
  class AppResourceFluidDb < AppResource
    def connect(uri)
      FluidDb::Db(uri)
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
