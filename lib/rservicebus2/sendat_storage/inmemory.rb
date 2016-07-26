module RServiceBus2
    # Send at storage in memory
    class SendAtStorageInMemory
      def initialize(_uri)
        @list = []
      end

      def add(msg)
        @list << msg
      end

      def all
        @list
      end

      def delete(idx)
        @list.delete_at(idx)
      end
    end
end
