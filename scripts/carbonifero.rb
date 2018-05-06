require File.expand_path(File.dirname(__FILE__) + '/configuration.rb')
require File.expand_path(File.dirname(__FILE__) + '/common.rb')
require File.expand_path(File.dirname(__FILE__) + '/lang.rb')
require File.expand_path(File.dirname(__FILE__) + '/dbms.rb')
require File.expand_path(File.dirname(__FILE__) + '/web.rb')
require File.expand_path(File.dirname(__FILE__) + '/dfs.rb')
require File.expand_path(File.dirname(__FILE__) + '/cluster.rb')

class Carbonifero
    def Carbonifero.configure(config, settings)
        numNodes = settings['nodes'] ||= 1
        r = numNodes..1
	    (r.first).downto(r.last).each do |i|
            Carbonifero.deploy(config, settings, i)
        end
    end

    def Carbonifero.deploy(config, settings, i)
        # Set The VM Provider
        ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

        scriptDir = File.dirname(__FILE__)

        # Configure The Box
        config.vm.define "carbonifero-#{i}" do |node|
            node.vm.box = settings["box"] ||= "ubuntu/xenial64"
            node.vm.box_version = settings["version"] ||= ">= 20160611.0.0"
            node.vm.hostname = "carbonifero-#{i}"

            if settings.has_key?("ip")
                tempIp=settings['ip'].split(".")
                hostIp="#{tempIp[0]}.#{tempIp[1]}.#{tempIp[2]}.#{Integer(tempIp[3])+i}"
            else
                hostIp="192.168.10.#{i}"
            end

            configuration = Configuration.new(config, settings, node, i)
            common = Common.new(config, settings, node, i)
            lang = Lang.new(config, settings, node, i)
            dbms = Dbms.new(config, settings, node, i)
            web = Web.new(config, settings, node, i)
            dfs = Dfs.new(config, settings, node, i)
            cluster = Cluster.new(config, settings, node, i)

            configuration.vbox()
            configuration.vmware()
            configuration.parallels()
            configuration.network(hostIp)
            configuration.security()
            configuration.folder()

            common.extras()
            common.host()
           

            # Install all selected languages
            if settings.include?("languages")
                if settings["languages"].to_s.length == 0
                    puts "Check your carbonifero.yaml file, you have no languages specified."
                    exit
                end
                settings["languages"].each do |language|
                    if (language == "php5.6")
                        lang.php56()
                    elsif (language == "php7.0")
                        lang.php70()
                    elsif (language == "php7.1")
                        lang.php71()
                    elsif (language == "php7.2")
                        lang.php72()
                    elsif (language == "nodejs")
                        lang.nodejs()
                    elsif (language == "java")
                        lang.java()
                    elsif (language == "ruby")
                        lang.ruby()
                    elsif (language == "scala")
                        lang.scala()
                    else
                        puts "Check your carbonifero.yaml file, you has specified wrong language."
                        exit
                    end
                end
            end

            # Install selected webserver
            if settings.has_key?("webserver")
                server = settings['webserver']
                if (server == "apache")
                    web.apache()
                    configuration.apache(hostIp, '000-default', '/var/www/html')
                elsif (server == "lighttpd")
                    web.lighttpd()
                    configuration.lighttpd(hostIp, 'default', '/var/www/html')
                elsif (server == "nginx")
                    web.nginx()
                    configuration.nginx(hostIp, 'default', '/var/www/html')
                else
                    puts "Check your carbonifero.yaml file, you has specified wrong webserver."
                    exit
                end
            end

            # Register All Of The Configured Webserver
            if settings.include? 'sites'
                if settings.has_key?("webserver")
                    web = settings['webserver']
                    settings["sites"].each do |site|
                        if (web == "apache")
                            configuration.apache(hostIp, site['map'], site['to'])
                        elsif (web == "lighttpd")
                            configuration.lighttpd(hostIp, site['map'], site['to'])
                        elsif (web == "nginx")
                            configuration.nginx(hostIp, site['map'], site['to'])
                        else
                            puts "Check your carbonifero.yaml file, you has specified wrong webserver."
                            exit
                        end
                    end
                else
                    puts "Check your carbonifero.yaml file, you have not specified webserver."
                    exit
                end
            end

            # Install selected DFS
            if settings.has_key?("dfs")
                server = settings['dfs']
                if (server == "hadoop")
                    lang.java()
                    dfs.hadoop()
                    configuration.hadoop()
                else
                    puts "Check your carbonifero.yaml file, you has specified wrong DFS."
                    exit
                end
            end

            # Install selected Cluster Processing
            if settings.has_key?("cluster")
                server = settings['cluster']
                if (server == "spark")
                    lang.java()
                    dfs.hadoop()
                    configuration.hadoop()
                    lang.scala()
                    cluster.spark()
                    configuration.spark()
                else
                    puts "Check your carbonifero.yaml file, you has specified wrong Cluster Processing."
                    exit
                end
            end

            # Install all selected dbms
            if settings.include?("dbms")
                if settings["dbms"].to_s.length == 0
                    puts "Check your carbonifero.yaml file, you have no dbms specified."
                    exit
                end
                settings["dbms"].each do |database|
                    if (database == "mariadb")
                        dbms.mariadb()
                    elsif (database == "mongodb")
                        dbms.mongodb()
                    elsif (database == "hbase")
                        lang.java()
                        dfs.hadoop()
                        configuration.hadoop()
                        lang.scala()
                        cluster.spark()
                        configuration.spark()
                        cluster.zookeeper()
                        configuration.zookeeper()
                        dbms.hbase()
                        configuration.hbase()
                    else
                        puts "Check your carbonifero.yaml file, you has specified wrong dbms."
                        exit
                    end
                end
            end

            # Configure All Of The Configured Databases
            if settings.has_key?("databases")
                settings["databases"].each do |db|
                    if settings.has_key?("dbms") and settings["dbms"].include? "mariadb"
                        configuration.mysql(db)
                    end

                    if settings.has_key?("dbms") and settings["dbms"].include? "mongodb"
                        configuration.mongodb(db)
                    end
                end
            end

            # Message
            node.vm.provision "shell" do |s|
                s.name = "Message from Developer"
                s.path = scriptDir + "/common/after-provision.sh"
                s.privileged = false
            end
        end
    end
end
