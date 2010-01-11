cloud :friendinterview do
  chef_repo '/Users/solo/development/ruby/davcro/chef'

  pool :app do
    instances 1..10

    bootstrap do
      copy_files 'config/authorized_keys' => '~/.ssh/authorized_keys',
                 'config/known_hosts'     => '~/.ssh/known_hosts',
                 'config/github_rsa'      => '~/.ssh/github_rsa',
                 'config/id_rsa'          => '~/.ssh/id_rsa',
                 'config/facebook.yml'    => '~/rails_config/facebook.yml',
                 'config/s3_assets.yml'   => '~/rails_config/s3_assets.yml'
      command 'chmod 0600 /root/.ssh/*'
      git_clone 'git://github.com/rubysolo/amazon-ec2.git'
    end

    # rds do
    #   username "root"
    #   password "passw0rd"
    # end

    load_balancer
  end
end