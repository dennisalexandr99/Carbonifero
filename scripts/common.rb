class Common
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__) + '/common'

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end
    
    def extras()
         #Install Extras
         @node.vm.provision "shell" do |s|
            s.name = "Installing Extras"
            s.path = @@scriptDir + "/install-extras.sh"
            s.privileged=false
        end
    end

    def host()
        #Install Host
        @node.vm.provision "shell" do |s|
            s.name = "Configuring Hosts"
            s.path = @@scriptDir + "/configure-host.sh"
            s.privileged=true
            s.args = [@settings['ip'] ||= "192.168.10.10", @settings['nodes']]
        end
    end
end