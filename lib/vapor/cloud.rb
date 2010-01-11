module Vapor
  # A cloud represents an entire infrastructure
  # contains many pools
  # relies on many services
  class Cloud < Base
    properties :name, :chef_repo
    attr_reader :pools

    def after_initialize
      @pools = {}
    end

    def pool(name, &block)
      @pools[name] = Pool.new(self, name)
      @pools[name].instance_eval(&block)
      @pools[name]
    end

    def start
      @pools.each do |name, p|
        puts "------ starting pool #{name}"

        p.rds_instances.each do |name, r|
          puts "       rds instance: #{name}"
          r.start
        end

        p.load_balancers.each do |name, lb|
          puts "      load balancer: #{name}"
          lb.start
        end

        p.start
      end
    end

    def stop
      @pools.each do |name, p|
        puts "------ stopping pool #{name}"
        p.rds_instances.each do |name, r|
          puts "       rds instance: #{name}"
          r.stop
        end
        p.stop
      end
    end

    def show
      puts "Cloud #{name}:"
      @pools.each do |name, p|
        puts "------ pool #{name}"
        p.rds_instances.each do |name, r|
          puts "       rds instance: #{name}"
          r.show
        end
        p.show
      end
    end
  end
end