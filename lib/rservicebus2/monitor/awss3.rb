# frozen_string_literal: true

require 'aws-sdk-s3'

module RServiceBus2
  # Monitor S3 Bucket for objects
  class MonitorAWSS3 < Monitor
    def connect(uri)
      @bucket_name = uri.path
      @bucket_name[0] = ''

      @region = uri.host

      @s3_client = Aws::S3::Client.new(region: @region)
      @input_filter = []
    end

    def process_content(content)
      content
    end

    def process_path(object_key)
      # content = read_content_from_object(object_key)
      resp = @s3_client.get_object(bucket: @bucket_name, key: object_key)

      # call #read or #string on the response body
      content = resp.body.read
      payload = process_content(content)

      send(payload, URI.parse(CGI.escape("s3://#{@region}/#{@bucket_name}/#{object_key}")))

      @s3_client.delete_object({ bucket: @bucket_name, key: object_key })

      content
    end

    def look
      file_processed = 0
      max_files_processed = 2

      objects = @s3_client.list_objects_v2(bucket: @bucket_name, max_keys: max_files_processed).contents

      objects.each do |object|
        RServiceBus2.log "Ready to process, #{object.key}"
        process_path(object.key)

        file_processed += 1
        RServiceBus2.log "Processed #{file_processed} of #{objects.length}."
        RServiceBus2.log "Allow system tick #{self.class.name}"
      end
    end
  end
end
