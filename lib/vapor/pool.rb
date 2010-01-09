module Vapor
  # A pool represents a group of instances within a cloud
  # belongs to a pool
  # relies on many services
  class Pool < Base
    properties :cloud, :recipe, :minimum_instances => 1, :maximum_instances => 10, :rds_instances => {}, :load_balancers => {}, :availability_zones => ['us-east-1a']

    def after_initialize
      self.cloud = parent
      self.recipe = proper_name
    end

    def proper_name
      "#{cloud.name}-#{name}"
    end

    def keypair
      @keypair ||= Keypair.new(proper_name)
    end

    def security_group
      @security_group ||= SecurityGroup.new(proper_name)
    end

    def instances(instance_count)
      case instance_count
      when Fixnum
        minimum_instances = maximum_instances = instance_count
      when Range
        minimum_instances = instance_count.first
        maximum_instances = instance_count.last
      end
    end

    def rds(name=nil, &block)
      rds_name = name || "#{proper_name}-rds"
      rds_instances[rds_name] = Rds.new(self, :name => rds_name)
      rds_instances[rds_name].instance_eval(&block) if block
    end

    def load_balancer(name=nil, &block)
      lb_name = name || "#{proper_name}-lb"
      load_balancers[lb_name] = ElasticLoadBalancer.new(self, :name => lb_name)
      load_balancers[lb_name].instance_eval(&block) if block
    end

    def start
      # launch enough ec2 instances to meet minimum_instances requirement
      puts "there are #{running_instances.length} running instances in the pool."
      need_to_launch = minimum_instances - running_instances.length # TODO : include booting instances

      if need_to_launch > 0
        puts "launching #{need_to_launch} instances to meet minimum_instances requirement..."
        Ec2Instance.new(self).start(need_to_launch)
      else
        puts "minimum_instances requirement already met."
      end
    end

    def stop
      # shut down a pool
      puts "there are #{running_instances.length} running instances in the pool."
      running_instances.each do |instance|
        puts " -- stopping instance #{instance.instance_id}..."
        instance.stop
      end
    end

    def show
      if ec2_instances.length == 0
        puts " -- no instances in EC2!"
      else
        puts " -- current instances:"
        puts ['instance id', 'status', 'private ip', 'public ip', 'dns'].join("\t")
        ec2_instances.each do |instance|
          puts [instance.instance_id, instance.status, instance.private_ip, instance.public_ip, instance.public_dns].join("\t")
            # ec2_status:
            #   keyName: friendinterview-app
            #   blockDeviceMapping:
            #   ramdiskId: ari-a51cf9cc
            #   productCodes:
            #   kernelId: aki-a71cf9ce
            #   launchTime: "2010-01-08T21:46:15.000Z"
            #   amiLaunchIndex: "0"
            #   imageId: ami-ed46a784
            #   instanceType: m1.small
            #   reason:
            #   rootDeviceType: instance-store
            #   placement:
            #     availabilityZone: us-east-1a
            #   monitoring:
            #     state: disabled
            #   instanceState:
            #     name: running
            #     code: "16"
            #
        end
      end
    end

    def ssh(instance_number) # TODO : specify instance by ID
      if running_instances.empty?
        puts "No running instances!"
      else
        puts "[ssh] connecting to #{instance_number}..."
        running_instances[instance_number].ssh
      end
    end

    private

    def ec2
      AwsService.ec2
    end

    def running_instances
      ec2_instances(:running)
    end

    def ec2_instances(status_filter=:all)
      current_status.select do |instance|
        status_filter == :all || instance.status == status_filter.to_s
      end
    end

    def current_status(reload=false)
      reset_cache if reload
      @current_status ||= begin
        (ec2.describe_instances.reservationSet || []).map do |r|
          r.last.map do |i|
            i.instancesSet.item.map do |ii|
              Ec2Instance.new(self, :ec2_status => ii)
            end
          end
        end
      end.flatten
    # rescue AWS::InvalidClientTokenId => e # AWS credentials invalid
    #   puts "Invalid AWS credentials: #{e}"
    #   raise e
    # rescue Exception => e
    #   []
    end

    def reset_cache
      @current_status = nil
    end

  end
end