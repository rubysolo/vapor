require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PoolTest < Test::Unit::TestCase
  include Vapor

  def setup
    @test_cloud = Cloud.new(self, 'test_cloud')
    @test_cloud.pool :test_pool do
      instances 1
    end
    @test_pool = @test_cloud.pools[:test_pool]
  end

  def test_new_pool
    assert @test_pool.is_a?(Pool)
  end

  def test_instances_accessor
    assert_equal 1, @test_pool.minimum_instances
    assert_equal 1, @test_pool.maximum_instances
  end

  def test_automatic_bootstrapping
    @auto_bootstrap = @test_cloud.pool :auto_bootstrap do
      bootstrap do
        'echo "hello" >> /tmp/user_data.log'
      end
    end

    assert_equal 'user_data', @auto_bootstrap.bootstrap_mode
  end

  def test_pools_are_independent
    @big_pool   = @test_cloud.pool(:big_app)   { rds }
    @small_pool = @test_cloud.pool(:small_app) { rds }

    assert @test_pool.rds_instances.empty?, @test_pool.rds_instances.keys.join(', ')
    assert_equal ['test_cloud-big_app-rds'], @big_pool.rds_instances.keys
    assert_equal ['test_cloud-small_app-rds'], @small_pool.rds_instances.keys
  end

  def test_pool_ec2_data_scoped_by_security_group
    AWS::EC2::Base.any_instance.stubs(:describe_instances).returns(
      AWS::Response.parse(:xml => open(File.join(FIXTURES_PATH, "ec2_describe_instances.xml")).read)
    )

    pool_instances = @test_pool.ec2_instances.map{|i| i.instance_id }
    assert pool_instances.include?('i-7fd89416'), 'pool should have instance i-7fd89416'
    assert ! pool_instances.include?('i-7f000516'), 'pool should not have instance i-7f000516'
  end
end
