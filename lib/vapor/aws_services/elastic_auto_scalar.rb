module Vapor
  class ElasticAutoScalar < AwsService
    def start
      as.create_launch_configuration(
        :launch_configuration_name => new_launch_configuration_name,
        :image_id                  => image_id,
        :instance_type             => instance_type,
        :security_groups           => parent.security_group_names,
        :key_name                  => keypair.to_s,
        :user_data                 => user_data,
        :kernel_id                 => kernel_id,
        :ramdisk_id                => ramdisk_id,
        :block_device_mappings     => block_device_mappings
      )
    end
  end
end