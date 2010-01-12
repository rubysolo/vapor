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
    @big_pool = @test_cloud.pool :big_app do
      rds
    end

    @small_pool = @test_cloud.pool :small_app do
      rds
    end

    assert @test_pool.rds_instances.empty?, @test_pool.rds_instances.keys.join(', ')
    assert_equal ['test_cloud-big_app-rds'], @big_pool.rds_instances.keys
    assert_equal ['test_cloud-small_app-rds'], @small_pool.rds_instances.keys
  end
end
