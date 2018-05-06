class Dfs
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__) + '/dfs'

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end

    def hadoop()
        @node.vm.provision "shell" do |s|
            s.name ="Installing Hadoop FS"
            s.path = @@scriptDir + "/install-hadoop.sh"
            s.privileged= false
        end
    end
end