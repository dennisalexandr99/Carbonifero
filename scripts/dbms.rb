class Dbms
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__) + '/dbms'

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end

    def mariadb()
        if @i==1
            @node.vm.provision "shell" do |s|
                s.name ="Installing MariaDB"
                s.path = @@scriptDir + "/install-mariadb.sh"
                s.privileged=true
            end
        end
    end

    def mongodb()
        if @i<=((@settings['nodes']||=1)+1/(@settings['replication']||=2))
            @node.vm.provision "shell" do |s|
                s.name ="Installing MongoDB"
                s.path = @@scriptDir + "/install-mongodb.sh"
                s.privileged=true
            end
        end
    end

    def hbase()
        @node.vm.provision "shell" do |s|
            s.name ="Installing HBase"
            s.path = @@scriptDir + "/install-hbase.sh"
            s.privileged=false
        end
    end

    def cassandra()
        @node.vm.provision "shell" do |s|
            s.name ="Installing Cassandra"
            s.path = @@scriptDir + "/install-cassandra.sh"
            s.privileged=false
        end
    end
end