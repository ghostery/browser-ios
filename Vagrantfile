Vagrant.configure("2") do |config|
    config.vm.box = "ios-xcode9.2"
    
    config.vm.define "priosx92" do |priosx92|
        priosx92.vm.hostname ="priosx92"
        
        priosx92.vm.network "public_network", :bridge => "en0", auto_config: false
        priosx92.vm.boot_timeout = 900
        priosx92.vm.provider "vmware_fusion" do |v|
            v.name = "priosx92"
            v.whitelist_verified = true
            v.gui = false
            v.memory = ENV["NODE_MEMORY"]
            v.cpus = ENV["NODE_CPU_COUNT"]
            v.cpu_mode = "host-passthrough"
            v.vmx["remotedisplay.vnc.enabled"] = "TRUE"
            v.vmx["RemoteDisplay.vnc.port"] = ENV["NODE_VNC_PORT"]
            v.vmx["ethernet0.pcislotnumber"] = "33"
        end
        priosx92.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL#!/bin/bash -l
            set -e
            set -x
            rm -f agent.jar
            curl -LO #{ENV['JENKINS_URL']}/jnlpJars/agent.jar
            nohup java -jar agent.jar -jnlpUrl #{ENV['JENKINS_URL']}/computer/#{ENV['NODE_ID']}/slave-agent.jnlp -secret #{ENV["NODE_SECRET"]} &
        SHELL
    end
end