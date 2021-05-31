# frozen_string_literal: true

require 'zlib'
require 'yaml'
require 'uuidtools'

module RServiceBus2
  # This is the top level message that is passed around the bus
  class Message
    attr_reader :return_address, :msg_id,
                :last_error_source_queue, :last_error_string, :correlation_id,
                :sendat, :error_list

    attr_accessor :remote_host_name, :remote_queue_name, :send_at

    # Constructor
    #
    # @param [Object] msg The msg to be sent
    # @param [Object] returnAddress A queue to which the destination message
    #  handler can send replies
    # rubocop:disable Metrics/MethodLength
    def initialize(msg, return_address, correlation_id = nil)
      if RServiceBus2.check_environment_variable('RSBMSG_COMPRESS')
        @compressed = true
        @_msg = Zlib::Deflate.deflate(YAML.dump(msg))
      else
        @compressed = false
        @_msg = YAML.dump(msg)
      end

      @correlation_id = correlation_id
      @return_address = return_address

      @createdat = Time.now

      @msg_id = UUIDTools::UUID.random_create
      @error_list = []
    end
    # rubocop:enable Metrics/MethodLength

    # If an error occurs while processing the message, this method allows details of the error to held
    # next to the msg.
    #
    # Error(s) are held in an array, which allows current error information to be held, while still
    # retaining historical error messages.
    #
    # @param [Object] source_queue The name of the queue to which the msg should be returned
    # @param [Object] error_string A readible version of what occured
    def add_error_msg(source_queue, error_string)
      @last_error_source_queue = source_queue
      @last_error_string = error_string

      @error_list << RServiceBus2::ErrorMessage.new(source_queue, error_string)
    end

    # @return [Object] The msg to be sent
    def msg
      return RServiceBus2.safe_load(Zlib::Inflate.inflate(@_msg)) if @compressed == true

      RServiceBus2.safe_load(@_msg)
    rescue ArgumentError => e
      raise e if e.message.index('undefined class/module ').nil?

      puts e.message
      msg_name = e.message.sub('undefined class/module ', '')

      raise ClassNotFoundForMsg, msg_name
    end
  end
end
