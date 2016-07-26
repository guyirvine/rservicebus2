require 'uri'

module RServiceBus2
  # Configure AppResources for an rservicebus host
  class ConfigureAppResource
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,CyclomaticComplexity
    def get_resources(env, host, state_manager, saga_storage)
      # rm = resource_manager
      rm = ResourceManager.new(state_manager, saga_storage)
      env.each do |k, v|
        if v.is_a?(String) && k.start_with?('RSBFDB_')
          uri = URI.parse(v)
          require 'rservicebus2/appresource/fluiddb'
          rm.add k.sub('RSBFDB_', ''), AppResourceFluidDb.new(host, uri)
        elsif v.is_a?(String) && k.start_with?('RSB_')
          uri = URI.parse(v)
          case uri.scheme
          when 'dir'
            require 'rservicebus2/appresource/dir'
            rm.add k.sub('RSB_', ''), AppResourceDir.new(host, uri)
          when 'file'
            require 'rservicebus2/appresource/file'
            rm.add k.sub('RSB_', ''), AppResourceFile.new(host, uri)
          else
            abort("Scheme, #{uri.scheme}, not recognised when configuring
                  app resource, #{k}=#{v}")
          end
        end
      end

      rm
    end
  end
end
