class Lang
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__) + '/lang'

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end

    def php56()
        @node.vm.provision "shell" do |s|
            s.name = "Installing PHP 5.6"
            s.path = @@scriptDir + "/install-php56.sh"
            s.privileged=true
        end
    end

    def php70()
        @node.vm.provision "shell" do |s|
            s.name = "Installing PHP 7.0"
            s.path = @@scriptDir + "/install-php70.sh"
            s.privileged=true
        end
    end

    def php71()
        @node.vm.provision "shell" do |s|
            s.name = "Installing PHP 7.1"
            s.path = @@scriptDir + "/install-php71.sh"
            s.privileged=true
        end
    end

    def php72()
        @node.vm.provision "shell" do |s|
            s.name = "Installing PHP 7.0"
            s.path = @@scriptDir + "/install-php72.sh"
            s.privileged=true
        end
    end

    def nodejs()
        @node.vm.provision "shell" do |s|
            s.name ="Installing NodeJS"
            s.path = @@scriptDir + "/install-nodejs.sh"
            s.privileged=true
        end
    end

    def java()
        @node.vm.provision "shell" do |s|
            s.name ="Installing Java"
            s.path = @@scriptDir + "/install-java.sh"
            s.privileged=false
        end
    end

    def ruby()
        @node.vm.provision "shell" do |s|
            s.name ="Installing Ruby"
            s.path = @@scriptDir + "/install-ruby.sh"
            s.privileged=true
        end
    end

    def scala()
        @node.vm.provision "shell" do |s|
            s.name ="Installing Scala"
            s.path = @@scriptDir + "/install-scala.sh"
            s.privileged=false
        end
    end
end