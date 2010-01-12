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
    AwsService.stubs(:aws_access_key).returns('fake-access-key')

    @bootstrapped_pool = @test_cloud.pool :auto_bootstrap do
      bootstrap do
        copy_files 'config/id_rsa' => '~/.ssh/id_rsa'
        command 'chmod 0600 *' => '~/.ssh/id_rsa'
        git_clone 'git://github.com/mr_excitement/awesomeness.git'
        'echo "hello" >> /tmp/user_data.log'
      end
    end
    @bootstrapped_instance = Ec2Instance.new(@bootstrapped_pool)
    user_data = @bootstrapped_instance.send(:user_data)

    assert_match %r{mkdir -p /root/.ssh}, user_data
    assert_match %r{cd /root/.ssh}, user_data
    assert_match %r{chmod 0600 \*}, user_data
    assert_match %r{echo "hello"}, user_data
    assert_match %r{cd /tmp\ngit clone git://github.com/mr_excitement/awesomeness.git}, user_data
    assert_match %r{echo "fake-access-key" > /root/.aws/access_key}, user_data
  end
end