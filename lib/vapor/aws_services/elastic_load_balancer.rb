module Vapor
  class ElasticLoadBalancer < AwsService
    def start
      # set up a new elastic load balancer
      elb.create_load_balancer(
        :availability_zones => pool.availability_zones,
        :load_balancer_name => name,
        # TODO : make listener details configurable...
        :listeners => [{:protocol => 'http', :load_balancer_port => 80, :instance_port => 80}]
      )
    end

    def stop
      elb.delete_load_balancer(:load_balancer_name => name)
    end

    def name
      options[:name]
    end
  end
end

