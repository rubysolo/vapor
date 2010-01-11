require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class Ec2InstanceTest < Test::Unit::TestCase
  include Vapor

  def setup
    @test_cloud = Cloud.new(self, 'test_cloud')
    @test_pool = Pool.new(@test_cloud, 'test_pool')
    @ec2_instance = Ec2Instance.new(@test_pool)
  end

  def test_new_instance
    assert @ec2_instance.kind_of?(Ec2Instance)
  end

  def test_user_data_bootstrapping
    @bootstrapped_pool = @test_cloud.pool :auto_bootstrap do
      bootstrap do
        'echo "hello" >> /tmp/user_data.log'
      end
    end
    @bootstrapped_instance = Ec2Instance.new(@bootstrapped_pool)

    assert_match /echo "hello"/, @bootstrapped_instance.send(:user_data)
  end
end