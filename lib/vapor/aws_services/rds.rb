module Vapor
  class Rds < AwsService
    properties :username, :password, :db_name, :storage => 5, :instance_class => 'db.m1.small', :engine => 'MySQL5.1'

    def start
      # set up a new rds instance
      params = {
        :db_instance_identifier => name,
        :allocated_storage      => storage,
        :db_instance_class      => instance_class,
        :engine                 => engine,
        :master_username        => username,
        :master_user_password   => password,
        :db_name                => db_name || to_db_name(pool.proper_name)
      }

      # TODO : optional params : :port, :db_parameter_group, :db_security_groups, :availability_zone, :preferred_backup_window, :backend_retention_period
      puts " -- starting rds instance #{name}"
      rds.create_db_instance(params)
      # TODO : wait for availability
    end

    def name
      options[:name]
    end

    def aws_status
      instances[name]
    end

    def available?
      aws_status && aws_status.DBInstanceStatus == "available"
    end

    def dns_name
      available? ? aws_status.Endpoint.Address : 'rds-pending-setup'
    end

    def stop
      if available?
        puts " -- stopping rds instance #{name}..."
        rds.delete_db_instance(:db_instance_identifier => name, :skip_final_snapshot => "true")
      else
        puts " -- rds instance #{name} not running."
      end
    end

    def show
      if instance = instances[name]
        puts ['instance id', 'status', 'storage'].join("\t")
        puts [instance.DBInstanceIdentifier, instance.DBInstanceStatus, instance.AllocatedStorage].join("\t")
      else
        puts " rds instance not available."
      end
      # puts instances[name].to_yaml
      # ---
      # PreferredMaintenanceWindow: sun:05:00-sun:09:00
      # DBName: friendinterview_app_rds
      # Engine: mysql5.1
      # PendingModifiedValues:
      #   MasterUserPassword: "****"
      # MasterUsername: root
      # DBInstanceClass: db.m1.small
      # DBInstanceStatus: creating
      # BackupRetentionPeriod: "1"
      # DBInstanceIdentifier: friendinterview-app-rds
      # AllocatedStorage: "5"
      # DBSecurityGroups:
      #   DBSecurityGroup:
      #     Status: active
      #     DBSecurityGroupName: default
      # DBParameterGroups:
      #   DBParameterGroup:
      #     DBParameterGroupName: default.mysql5.1
      #     ParameterApplyStatus: in-sync
      # PreferredBackupWindow: 03:00-05:00
    end

    def data
      {
        :host => dns_name,
        :database => db_name,
        :username => username,
        :password => password
      }
    end

    private

    def instances
      @instances ||= begin
        ec2_data = (rds.describe_db_instances.DescribeDBInstancesResult.DBInstances || {})['DBInstance'] || []
        ec2_data = [ec2_data] unless ec2_data.is_a?(Array)
        ec2_data.inject({}) {|hash, instance| hash.update(instance.DBInstanceIdentifier => instance) }
      end
    end

    def to_db_name(string)
      string.gsub(/\-/, '_')
    end
  end
end