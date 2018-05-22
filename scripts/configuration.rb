class Configuration
    # Configure Local Variable To Access Scripts From Remote Location
    @@scriptDir = File.dirname(__FILE__)

    def initialize(config, settings, node, i)
        @config = config
        @settings = settings
        @node = node
        @i = i
    end

    def vbox()
        # Configure A Few VirtualBox Settings
        @node.vm.provider "virtualbox" do |vb|
            vb.name = "carbonifero-#{@i}"
            vb.customize ["modifyvm", :id, "--memory", @settings["memory"] ||= "1024"]
            vb.customize ["modifyvm", :id, "--cpus", @settings["cpus"] ||= "1"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", @settings["natdnshostresolver"] ||= "on"]
            vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
            if @settings.has_key?("gui") && @settings["gui"]
                vb.gui = true
            end
        end
    end

    def vmware()
        # Configure A Few VMware Settings
        ["vmware_fusion", "vmware_workstation"].each do |vmware|
            @node.vm.provider vmware do |v|
                v.vmx["displayName"] = "carbonifero-#{@i}"
                v.vmx["memsize"] = @settings["memory"] ||= 1
                v.vmx["numvcpus"] = @settings["cpus"] ||= 1
                v.vmx["guestOS"] = "ubuntu-64"
                if @settings.has_key?("gui") && @settings["gui"]
                    v.gui = true
                end
            end
        end
    end

    def parallels()
        # Configure A Few Parallels Settings
        @node.vm.provider "parallels" do |v|
            v.name = @settings["name"] ||= "carbonifero-#{@i}"
            v.update_guest_tools = @settings["update_parallels_tools"] ||= false
            v.memory = @settings["memory"] ||= 1024
            v.cpus = @settings["cpus"] ||= 1
        end
    end

    def network(ip)
        # Configure A Private Network IP
        if @settings["ip"] != "autonetwork"
            @node.vm.network :private_network, ip: ip
        else
            @node.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true
        end

        # Configure Additional Networks
        if @settings.has_key?("networks")
            @settings["networks"].each do |network|
                @node.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil, netmask: network["netmask"] ||= "255.255.255.0"
            end
        end

         # Override Default SSH port on the host
         if (@settings.has_key?("default_ssh_port"))
            @node.vm.network :forwarded_port, guest: 22, host: @settings["default_ssh_port"], auto_correct: false, id: "ssh"
        end

        # Standardize Ports Naming Schema
        if (@settings.has_key?("ports"))
            @settings["ports"].each do |port|
                port["guest"] ||= port["to"]
                port["host"] ||= port["send"]
                port["protocol"] ||= "tcp"
            end
        else
            @settings["ports"] = []
        end

        # Default Port Forwarding
        default_ports = {
            80 => 8000+@i,
            443 => 44300+@i,
        }

        # Use Default Port Forwarding Unless Overridden
        unless @settings.has_key?("default_ports") && @settings["default_ports"] == false
            default_ports.each do |guest, host|
                unless @settings["ports"].any? { |mapping| mapping["guest"] == guest }
                    @node.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
                end
            end
        end

        # Add Custom Ports From Configuration
        if @settings.has_key?("ports")
            @settings["ports"].each do |port|
                @node.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: true
            end
        end
    end

    def security()
        # Allow Multiple Key
        @config.ssh.insert_key = false

        # Allow SSH Agent Forward from The Box
        @config.ssh.forward_agent = true

        # Configure The Public Key For SSH Access
        if @settings.include? 'authorize'
            if File.exists? File.expand_path(@settings["authorize"])
                @node.vm.provision "shell" do |s|
                    s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/vagrant/.ssh/authorized_keys"
                    s.args = [File.read(File.expand_path(@settings["authorize"]))]
                end
            end
        end

        # Copy The SSH Private Keys To The Box
        if @settings.include? 'keys'
            if @settings["keys"].to_s.length == 0
                puts "Check your carbonifero.yaml file, you have no private key(s) specified."
                exit
            end
            @settings["keys"].each do |key|
                if File.exists? File.expand_path(key)
                    @node.vm.provision "shell" do |s|
                        s.privileged = false
                        s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
                        s.args = [File.read(File.expand_path(key)), key.split('/').last]
                    end
                else
                    puts "Check your carbonifero.yaml file, the path to your private key does not exist."
                    exit
                end
            end
        end
    end

    def folder()
        # Copy User Files Over to VM
        if @settings.include? 'copy'
            @settings["copy"].each do |file|
                @node.vm.provision "file" do |f|
                    f.source = File.expand_path(file["from"])
                    f.destination = file["to"].chomp('/') + "/" + file["from"].split('/').last
                end
            end
        end

        # Register All Of The Configured Shared Folders
        if @settings.include? 'folders'
            @settings["folders"].each do |folder|
                if File.exists? File.expand_path(folder["map"])
                    mount_opts = []

                    if (folder["type"] == "nfs")
                        mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1', 'nolock']
                    elsif (folder["type"] == "smb")
                        mount_opts = folder["mount_options"] ? folder["mount_options"] : ['vers=3.02', 'mfsymlinks']
                    end

                    # For b/w compatibility keep separate 'mount_opts', but merge with options
                    options = (folder["options"] || {}).merge({ mount_options: mount_opts })

                    # Double-splat (**) operator only works with symbol keys, so convert
                    options.keys.each{|k| options[k.to_sym] = options.delete(k) }

                    @node.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options

                    # Bindfs support to fix shared folder (NFS) permission issue on Mac
                    if (folder["type"] == "nfs")
                        if Vagrant.has_plugin?("vagrant-bindfs")
                            @config.bindfs.bind_folder folder["to"], folder["to"]
                        end
                    end
                else
                    @node.vm.provision "shell" do |s|
                        s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in carbonifero.yaml\""
                    end
                end
            end
        end

        # Vagrant Cachier
        if Vagrant.has_plugin?("vagrant-cachier")
            # Configure cached packages to be shared between instances of the same base box.
            # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
            @config.cache.scope = :box
            @config.cache.synced_folder_opts = {
                owner: "vagrant",
                group: "vagrant"
            }
            # For more information please check http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
        end

    end

    def mysql(db)
        @node.vm.provision "shell" do |s|
            s.name = "Configuring MySQL Database: " + db
            s.path = @@scriptDir + "/dbms/configure-mysql.sh"
            s.args = [db]
        end
    end

    def mongodb(db)
        @node.vm.provision "shell" do |s|
            s.name = "Configuring Mongo Database: " + db
            s.path = @@scriptDir + "/dbms/configure-mongo.sh"
            s.args = [db]
        end
    end

    def hbase(db = "carbonifero")
        @node.vm.provision "shell" do |s|
            s.name ="Configuring HBase Database"
            s.path = @@scriptDir + "/dbms/configure-hbase.sh"
            s.privileged= true
            s.args = [db]
        end
    end

    def cassandra()
        @node.vm.provision "shell" do |s|
            s.name = "Configuring Cassandra"
            s.path = @@scriptDir + "/dbms/configure-cassandra.sh"
            s.privileged=true
            s.args = [@settings['ip'] ||= "192.168.10.10", @settings['nodes']]
        end
    end

    def apache(ip,name,folder)
        @node.vm.provision "shell" do |s|
            s.name ="Configuring Apache2"
            s.path = @@scriptDir + "/web/configure-apache.sh"
            s.privileged= true
            s.args = [ip,name,folder]
        end
    end

    def lighttpd(ip,name,folder)
        @node.vm.provision "shell" do |s|
            s.name ="Configuring Lighttpd"
            s.path = @@scriptDir + "/web/configure-lighttpd.sh"
            s.privileged= true
            s.args = [ip,name,folder]
        end
    end

    def nginx(ip,name,folder)
        @node.vm.provision "shell" do |s|
            s.name ="Configuring Nginx"
            s.path = @@scriptDir + "/web/configure-nginx.sh"
            s.privileged= true
            s.args = [ip,name,folder]
        end
    end

    def hadoop()
        @node.vm.provision "shell" do |s|
            s.name ="Configuring Hadoop FS"
            s.path = @@scriptDir + "/dfs/configure-hadoop.sh"
            s.args = [@settings['nodes']||=1,@settings['replication']||=2, @i]
            s.privileged= false
        end
    end

    def spark()
        @node.vm.provision "shell" do |s|
            s.name ="Configuring Spark Cluster"
            s.path = @@scriptDir + "/cluster/configure-spark.sh"
            s.args = [@settings['ip'] ||= "192.168.10.10",@settings['nodes']||=1,@settings['replication']||=2, @i]
            s.privileged= true
        end
    end

    def zookeeper()
        @node.vm.provision "shell" do |s|
            s.name ="Configuring Zookeeper Cluster"
            s.path = @@scriptDir + "/cluster/configure-zookeeper.sh"
            s.privileged= true
            s.args = [@settings['nodes']||=1,@settings['replication']||=2, @i]
        end
    end
end