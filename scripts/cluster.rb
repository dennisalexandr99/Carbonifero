class Cluster
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__) + '/cluster'

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end

    def spark()
        #Install Spark
        @node.vm.provision "shell" do |s|
            s.name = "Installing Spark Cluster"
            s.path = @@scriptDir + "/install-spark.sh"
            s.privileged=false
        end
    end

    def zookeeper()
        # Install Zookeeper
        @node.vm.provision "shell" do |s|
            s.name = "Installing Zookeeper Cluster"
            s.path = @@scriptDir + "/install-zookeeper.sh"
            s.privileged=false
        end
    end
end