# frozen_string_literal: true

require 'uri'

module RServiceBus2
  # Configure AppResources for an rservicebus host
  class ConfigureAppResource
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    def get_resources(env, host, state_manager, saga_storage)
      rm = ResourceManager.new(state_manager, saga_storage)
      # rubocop:disable Metrics/BlockLength
      env.each do |k, v|
        if v.is_a?(String) && k.start_with?('RSBFDB2_')
          uri = URI.parse(v)
          require 'rservicebus2/appresource/fluiddb2'

          k = k.sub('RSBFDB2_', '')
          rm.add k, AppResourceFluidDb2.new(host, uri)
        elsif v.is_a?(String) &&
              (k.start_with?('RSBFDB_') || v.index('fluiddb') == 0)
          v = v['fluiddb'.length..-1] if v.index('fluiddb') == 0
          uri = URI.parse(v)
          require 'rservicebus2/appresource/fluiddb'

          k = k.sub('RSBFDB_', '') if k.start_with?('RSBFDB_')
          rm.add k, AppResourceFluidDb.new(host, uri)
        elsif v.is_a?(String) && k.start_with?('RSB_')
          uri = URI.parse(v)
          case uri.scheme
          when 'dir'
            require 'rservicebus2/appresource/dir'
            rm.add k.sub('RSB_', ''), AppResourceDir.new(host, uri)
          when 'file'
            require 'rservicebus2/appresource/file'
            rm.add k.sub('RSB_', ''), AppResourceFile.new(host, uri)
          when 'awsdynamodb'
            require 'rservicebus2/appresource/awsdynamodb'
            rm.add k.sub('RSB_', ''), AppResourceAWSDynamoDb.new(host, uri)
          when 'awss3'
            require 'rservicebus2/appresource/awss3'
            rm.add k.sub('RSB_', ''), AppResourceAWSS3.new(host, uri)
          when 'awssqs'
            require 'rservicebus2/appresource/awssqs'
            rm.add k.sub('RSB_', ''), AppResourceAWSSQS.new(host, uri)
          else
            abort("Scheme, #{uri.scheme}, not recognised when configuring
                  app resource, #{k}=#{v}")
          end
        end
      end
      # rubocop:enable Metrics/BlockLength

      rm
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  end
end
