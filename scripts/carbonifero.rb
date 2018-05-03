class Carbonifero
    def Carbonifero.configure(config, settings)
        numNodes = settings['nodes'] ||= 1
        r = numNodes..1
	    (r.first).downto(r.last).each do |i|
            Carbonifero.deploy(config,settings,i)
        end
    end

    def Carbonifero.deploy(config, settings,i)
        # Configure Local Variable To Access Scripts From Remote Location
        scriptDir = File.dirname(__FILE__)

        # Set The VM Provider
        ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"
        
        # Allow SSH Agent Forward from The Box
        config.ssh.forward_agent = true

        # Configure The Box
        config.vm.define "carbonifero-#{i}" do |node|
            node.vm.box = settings["box"] ||= "ubuntu/xenial64"
            node.vm.box_version = settings["version"] ||= ">= 20160611.0.0"
            node.vm.hostname = "carbonifero-#{i}"

            # Configure A Private Network IP
            if settings["ip"] != "autonetwork"
                if settings.has_key?("ip")
                    tempIp=settings['ip'].split(".")
                    node.vm.network :private_network, ip: "#{tempIp[0]}.#{tempIp[1]}.#{tempIp[2]}.#{Integer(tempIp[3])+i}"
                else
                    node.vm.network :private_network, ip: "192.168.10.#{i}"
                end
            else
                node.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true
            end

            # Configure Additional Networks
            if settings.has_key?("networks")
                settings["networks"].each do |network|
                    node.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil, netmask: network["netmask"] ||= "255.255.255.0"
                end
            end

            # Configure A Few VirtualBox Settings
            node.vm.provider "virtualbox" do |vb|
                vb.name = "carbonifero-#{i}"
                vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "1024"]
                vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", settings["natdnshostresolver"] ||= "on"]
                vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
                if settings.has_key?("gui") && settings["gui"]
                    vb.gui = true
                end
            end

            # Configure A Few VMware Settings
            ["vmware_fusion", "vmware_workstation"].each do |vmware|
                node.vm.provider vmware do |v|
                    v.vmx["displayName"] = "carbonifero-#{i}"
                    v.vmx["memsize"] = settings["memory"] ||= 1
                    v.vmx["numvcpus"] = settings["cpus"] ||= 1
                    v.vmx["guestOS"] = "ubuntu-64"
                    if settings.has_key?("gui") && settings["gui"]
                        v.gui = true
                    end
                end
            end

            # Configure A Few Parallels Settings
            node.vm.provider "parallels" do |v|
                v.name = settings["name"] ||= "carbonifero-#{i}"
                v.update_guest_tools = settings["update_parallels_tools"] ||= false
                v.memory = settings["memory"] ||= 1024
                v.cpus = settings["cpus"] ||= 1
            end

            # Override Default SSH port on the host
            if (settings.has_key?("default_ssh_port"))
                node.vm.network :forwarded_port, guest: 22, host: settings["default_ssh_port"], auto_correct: false, id: "ssh"
            end

            # Standardize Ports Naming Schema
            if (settings.has_key?("ports"))
                settings["ports"].each do |port|
                    port["guest"] ||= port["to"]
                    port["host"] ||= port["send"]
                    port["protocol"] ||= "tcp"
                end
            else
                settings["ports"] = []
            end

            # Default Port Forwarding
            default_ports = {
                80 => 8000+i,
                443 => 44300+i,
                3306 => 33060+i,
                4040 => 4040+i,
                5432 => 54320+i,
                8025 => 8025+i,
                27017 => 27017+i
            }

            # Use Default Port Forwarding Unless Overridden
            unless settings.has_key?("default_ports") && settings["default_ports"] == false
                default_ports.each do |guest, host|
                    unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
                        node.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
                    end
                end
            end

            # Add Custom Ports From Configuration
            if settings.has_key?("ports")
                settings["ports"].each do |port|
                    node.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: true
                end
            end

            # Configure The Public Key For SSH Access
            if settings.include? 'authorize'
                if File.exists? File.expand_path(settings["authorize"])
                    node.vm.provision "shell" do |s|
                        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/vagrant/.ssh/authorized_keys"
                        s.args = [File.read(File.expand_path(settings["authorize"]))]
                    end
                end
            end

            # Copy The SSH Private Keys To The Box
            if settings.include? 'keys'
                if settings["keys"].to_s.length == 0
                    puts "Check your carbonifero.yaml file, you have no private key(s) specified."
                    exit
                end
                settings["keys"].each do |key|
                    if File.exists? File.expand_path(key)
                        node.vm.provision "shell" do |s|
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

            # Copy User Files Over to VM
            if settings.include? 'copy'
                settings["copy"].each do |file|
                    node.vm.provision "file" do |f|
                        f.source = File.expand_path(file["from"])
                        f.destination = file["to"].chomp('/') + "/" + file["from"].split('/').last
                    end
                end
            end

            # Register All Of The Configured Shared Folders
            if settings.include? 'folders'
                settings["folders"].each do |folder|
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

                        node.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options

                        # Bindfs support to fix shared folder (NFS) permission issue on Mac
                        if (folder["type"] == "nfs")
                            if Vagrant.has_plugin?("vagrant-bindfs")
                                config.bindfs.bind_folder folder["to"], folder["to"]
                            end
                        end
                    else
                        node.vm.provision "shell" do |s|
                            s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in carbonifero.yaml\""
                        end
                    end
                end
            end

            #Install Extras
            node.vm.provision "shell" do |s|
                s.name = "Configuring Hosts"
                s.path = scriptDir + "/config-host.sh"
                s.privileged=true
                s.args = [settings['ip'] ||= "192.168.10.10", settings['nodes']]
            end

            #Install Extras
            node.vm.provision "shell" do |s|
                s.name = "Installing Extras"
                s.path = scriptDir + "/install-extras.sh"
                s.privileged=false
            end

            # Install all selected dbms
            if settings.include?("dbms")
                if settings["dbms"].to_s.length == 0
                    puts "Check your carbonifero.yaml file, you have no dbms specified."
                    exit
                end
                settings["dbms"].each do |database|
                    if (database == "mariadb")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing MariaDB"
                            s.path = scriptDir + "/install-mariadb.sh"
                            s.privileged=true
                        end
                    elsif (database == "mongodb")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing MongoDB"
                            s.path = scriptDir + "/install-mongodb.sh"
                            s.privileged=true
                        end
                    else
                        puts "Check your carbonifero.yaml file, you has specified wrong dbms."
                        exit
                    end
                end
            end

            # Install all selected languages
            if settings.include?("languages")
                if settings["languages"].to_s.length == 0
                    puts "Check your carbonifero.yaml file, you have no languages specified."
                    exit
                end
                settings["languages"].each do |language|
                    if (language == "php5.6")
                        node.vm.provision "shell" do |s|
                            s.name = "Installing PHP 5.6"
                            s.path = scriptDir + "/install-php56.sh"
                            s.privileged=true
                        end
                    elsif (language == "php7.0")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing PHP 7.0"
                            s.path = scriptDir + "/install-php70.sh"
                            s.privileged=true
                        end
                    elsif (language == "php7.1")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing PHP 7.1"
                            s.path = scriptDir + "/install-php71.sh"
                            s.privileged=true
                        end
                    elsif (language == "php7.2")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing PHP 7.2"
                            s.path = scriptDir + "/install-php72.sh"
                            s.privileged=true
                        end
                    elsif (language == "nodejs")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing NodeJS"
                            s.path = scriptDir + "/install-nodejs.sh"
                            s.privileged=true
                        end
                    elsif (language == "java")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing Java"
                            s.path = scriptDir + "/install-java.sh"
                            s.privileged=true
                        end
                    elsif (language == "ruby")
                        node.vm.provision "shell" do |s|
                            s.name ="Installing Ruby"
                            s.path = scriptDir + "/install-ruby.sh"
                            s.privileged=true
                        end
                    else
                        puts "Check your carbonifero.yaml file, you has specified wrong language."
                        exit
                    end
                end
            end

            # Configure All Of The Configured Databases
            if settings.has_key?("databases")
                settings["databases"].each do |db|
                    node.vm.provision "shell" do |s|
                        s.name = "Creating MySQL Database: " + db
                        s.path = scriptDir + "/create-mysql.sh"
                        s.args = [db]
                    end

                    if settings.has_key?("mongodb") && settings["mongodb"]
                        node.vm.provision "shell" do |s|
                            s.name = "Creating Mongo Database: " + db
                            s.path = scriptDir + "/create-mongo.sh"
                            s.args = [db]
                        end
                    end

                    if settings.has_key?("couchdb") && settings["couchdb"]
                        node.vm.provision "shell" do |s|
                            s.name = "Creating Couch Database: " + db
                            s.path = scriptDir + "/create-couch.sh"
                            s.args = [db]
                        end
                    end
                end
            end
            # Message
            node.vm.provision "shell" do |s|
                s.name = "Message from Developer"
                s.path = scriptDir + "/after-provision.sh"
                s.privileged = false
            end
        end
    end
end
