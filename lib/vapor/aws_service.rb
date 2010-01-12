module Vapor
  class AwsService < Base
    property :pool, :options
    REQUIRED_ENVIRONMENTALS = [:aws_access_key, :aws_secret_key]

    def initialize(pool, options={})
      self.pool = pool
      self.options = options
    end

    def run
      raise "implement run in your subclass"
    end

    def wait_for(message, delay=5, &block)
      print message if message
      finished = false
      while ! finished
        finished = yield
        unless finished
          print "." if message
          sleep delay
        end
      end
      puts if message
    end

    class << self
      REQUIRED_ENVIRONMENTALS.each do |name|
        define_method name do
          ENV[name.to_s.upcase]
        end
      end

      def ec2
        @ec2 ||= AWS::EC2::Base.new( :access_key_id => aws_access_key, :secret_access_key => aws_secret_key )
      end

      def rds
        @rds ||= AWS::RDS::Base.new( :access_key_id => aws_access_key, :secret_access_key => aws_secret_key )
      end

      def elb
        @elb ||= AWS::ELB::Base.new( :access_key_id => aws_access_key, :secret_access_key => aws_secret_key )
      end

      def verify_environment
        REQUIRED_ENVIRONMENTALS.each do |name|
          raise "ENV['#{name.to_s.upcase}'] not set!" unless self.send(name)
        end
      end
    end

    def ec2
      self.class.ec2
    end

    def rds
      self.class.rds
    end

    def elb
      self.class.elb
    end

  end
end

Dir[File.join(File.dirname(__FILE__), 'aws_services', '*.rb')].each do |service|
  require service
end