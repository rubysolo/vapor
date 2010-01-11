module Vapor
  class Ec2Instance < AwsService
    property :pool, :ec2_status, :user => 'root', :image_id => 'ami-ed46a784', :instance_type => 'm1.small', :availability_zone => 'us-east-1a'

    def initialize(pool, options = {})
      self.pool = pool
      self.ec2_status = options[:ec2_status]
    end

    def start(instance_count=1)
      # start new EC2 instance(s)
      params = {
        :image_id          => image_id,
        :min_count         => instance_count,
        :max_count         => instance_count,
        :key_name          => pool.keypair.name,
        :security_group    => pool.security_group.name,
        :instance_type     => instance_type,
        :availability_zone => availability_zone
      }

      # does the pool want user_data bootstrapping?
      if pool.bootstrap_mode == 'user_data'
        params[:user_data] = user_data
      end

      puts "starting instance: #{params.to_yaml}..."

      ec2.run_instances(params)
      puts "instance start requested."
    end

    def stop
      ec2.terminate_instances(:instance_id => [self.instance_id])
    end

    # accessors for EC2 status data
    def instance_id
      ec2_status && ec2_status.instanceId
    end

    def status
      ec2_status && ec2_status.instanceState.name
    end

    def private_ip
      ec2_status && ec2_status.privateIpAddress
    end

    def private_dns
      ec2_status && ec2_status.privateDnsName
    end

    def public_ip
      ec2_status && ec2_status.ipAddress
    end

    def public_dns
      ec2_status && ec2_status.dnsName
    end

    # puts [instance.instance_id, instance.status, instance.private_ip, instance.public_ip, instance.public_dns].join("\t")

    # ec2_status:
    #   privateIpAddress: 10.212.117.235
    #   keyName: friendinterview-app
    #   blockDeviceMapping:
    #   ramdiskId: ari-a51cf9cc
    #   productCodes:
    #   ipAddress: 174.129.97.73
    #   kernelId: aki-a71cf9ce
    #   launchTime: "2010-01-08T21:46:15.000Z"
    #   amiLaunchIndex: "0"
    #   imageId: ami-ed46a784
    #   instanceType: m1.small
    #   reason:
    #   rootDeviceType: instance-store
    #   placement:
    #     availabilityZone: us-east-1a
    #   instanceId: i-37efc45f
    #   privateDnsName: ip-10-212-117-235.ec2.internal
    #   dnsName: ec2-174-129-97-73.compute-1.amazonaws.com
    #   monitoring:
    #     state: disabled
    #   instanceState:
    #     name: running
    #     code: "16"

    def ssh(commands=[], options={})
      ssh_cmd = "ssh #{user}@#{public_dns} #{ssh_options(options)}"
      if commands.empty?
        Kernel.system(ssh_cmd)
      else
        commands = commands.compact.join(' && ') if commands.is_a?(Array)
        system_run(ssh_cmd + "'#{commands}'")
      end
    end

    private

    # TODO : load user data scripts from a known path?
    def user_data
      [image_id, "default"].each do |basename|
        filepath = File.join(File.dirname(__FILE__), 'user_data', "#{basename}.sh")
        if File.exist?(filepath)
          baseline = IO.read(filepath).strip
          baseline << "\n#{pool.user_data}" unless pool.user_data.strip.empty?
          return baseline
        end
      end
      raise "no user data provided for image #{image_id}, and no default!"
    end

    def ssh_options(options)
      {
        "-i" => pool.keypair.local_path,
        "-o" =>"StrictHostKeyChecking=no"
      }.merge(options).map{|k,v| "#{k} #{v}" }.join(' ')
    end

    # TODO : migrate to net/ssh?
    def system_run(cmd, o={})
      opts = {:quiet => false, :sysread => 1024}.merge(o)
      buf = ""
      puts("Running command: #{cmd}")
      Open3.popen3(cmd) do |stdout, stdin, stderr|
        begin
          while (chunk = stdin.readpartial(opts[:sysread]))
            buf << chunk
            unless chunk.nil? || chunk.empty?
              $stdout.write(chunk) #if debugging? || verbose?
            end
          end
          err = stderr.readlines
          $stderr.write_nonblock(err)
        rescue SystemCallError => error
          err = stderr.readlines
          $stderr.write_nonblock(err)
        rescue EOFError => error
          err = stderr.readlines
          $stderr.write_nonblock(err)
          # used to do nothing
        end
      end
      unless $?.success?
        warn "Failed sshing. Check ~/.poolparty/ssh.log for details"
      end
      buf
    end
  end
end