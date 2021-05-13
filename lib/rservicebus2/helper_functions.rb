# frozen_string_literal: true

# Helper functions
module RServiceBus2
  def self.convert_dto_to_hash(obj)
    hash = {}
    obj.instance_variables.each do |var|
      hash[var.to_s.delete('@')] = obj.instance_variable_get(var)
    end
    hash
  end

  def self.convert_dto_to_json(obj)
    convert_dto_to_hash(obj).to_json
  end

  def self.log(string, ver: false)
    return if check_environment_variable('TESTING')

    type = ver ? 'VERB' : 'INFO'
    return unless check_environment_variable('VERBOSE') || !ver

    timestamp = Time.new.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{type}] #{timestamp} :: #{string}"
  end

  def self.rlog(string)
    return unless check_environment_variable('RSBVERBOSE')

    timestamp = Time.new.strftime('%Y-%m-%d %H:%M:%S')
    puts "[RSB] #{timestamp} :: #{string}"
  end

  def self.create_anonymous_class(name_for_class)
    new_anonymous_class = Class.new(Object)
    Object.const_set(name_for_class, new_anonymous_class)
    Object.const_get(name_for_class).new
  end

  def self.get_value(name, default = nil)
    value = ENV[name].nil? || ENV[name] == '' ? default : ENV[name]
    log "Env value: #{name}: #{value}"
    value
  end

  # rubocop:disable Metrics/MethodLength
  def self.send_msg(msg, response_queue = 'agent')
    require 'rservicebus2/endpointmapping'
    endpoint_mapping = EndpointMapping.new
    endpoint_mapping.configure
    queue_name = endpoint_mapping.get(msg.class.name)

    ENV['RSBMQ'] = 'beanstalk://localhost' if ENV['RSBMQ'].nil?
    agent = RServiceBus2::Agent.new
    Audit.new(agent).audit_to_queue(msg)
    agent.send_msg(msg, queue_name, response_queue)
  rescue QueueNotFoundForMsg => e
    raise StandardError, '' \
      "*** Queue not found for, #{e.message}\n" \
      "*** Ensure you have an environment variable set for this Message Type, eg, \n" \
      "*** MESSAGE_ENDPOINT_MAPPINGS=#{e.message}:<QueueName>\n"
  end
  # rubocop:enable Metrics/MethodLength

  def self.check_for_reply(queue_name)
    ENV['RSBMQ'] = 'beanstalk://localhost' if ENV['RSBMQ'].nil?
    agent = RServiceBus2::Agent.new
    msg = agent.check_for_reply(queue_name)
    Audit.new(agent).audit_incoming(msg)

    msg
  end

  def self.tick(string)
    puts "[TICK] #{Time.new.strftime('%Y-%m-%d %H:%M:%S.%6N')} ::
      #{caller[0]}. #{string}"
  end

  def self.check_environment_variable(string)
    return false if ENV[string].nil? || ENV[string] == ''
    return true if ENV[string] == true || ENV[string] =~ (/(true|t|yes|y|1)$/i)
    return false if ENV[string] == false ||
                    ENV[string].nil? ||
                    ENV[string] =~ (/(false|f|no|n|0)$/i)

    raise ArgumentError, "invalid value for Environment Variable: \"#{string}\""
  end
end
