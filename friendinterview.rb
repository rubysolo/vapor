cloud :friendinterview do
  chef_repo '/Users/solo/development/ruby/davcro/chef'

  pool :app do
    instances 1..10

    bootstrap do
    end

    # rds do
    #   username "root"
    #   password "passw0rd"
    # end

    load_balancer
  end
end