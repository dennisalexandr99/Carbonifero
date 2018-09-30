class Web
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__) + '/web'

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end

    def apache()
        if @i<=((@settings['nodes']||=1)+1/(@settings['replication']||=2))
            @node.vm.provision "shell" do |s|
                s.name ="Installing Apache"
                s.path = @@scriptDir + "/install-apache.sh"
                s.privileged= true
            end
        end
    end

    def lighttpd()
        if @i<=((@settings['nodes']||=1)+1/(@settings['replication']||=2))
            @node.vm.provision "shell" do |s|
                s.name ="Installing Lighttpd"
                s.path = @@scriptDir + "/install-lighttpd.sh"
                s.privileged= true
            end
        end
    end

    def nginx()
        if @i<=((@settings['nodes']||=1)+1/(@settings['replication']||=2))
            @node.vm.provision "shell" do |s|
                s.name ="Installing Nginx"
                s.path = @@scriptDir + "/install-nginx.sh"
                s.privileged= true
            end
        end
    end
end