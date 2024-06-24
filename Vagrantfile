# -*- mode: ruby -*-
# vi: set ft=ruby :

## configuration variables ##
# max number of worker nodes
N = 2
# each of components to install
k8s_V         = '1.30.0-1.1'                   # Kubernetes
ctrd_V        = '1.6.28-1'                     # Containerd
controller_IP = '192.168.1.10'                 # if ip have a issue, it changed. 
## /configuration variables ##

Vagrant.configure("2") do |config|

  #====================#
  # Control-Plane Node #
  #====================#

    config.vm.define "cp-k8s-#{k8s_V[0..5]}" do |cfg|
      cfg.vm.box = "sysnet4admin/Ubuntu-k8s"
      cfg.vm.provider "vmware_desktop" do |vb|
        vb.gui = true 
        vb.cpus = 2
        vb.memory = 1792
#        vb.vmx ["modifyvm", :id, "--groups", "/k8s-U#{k8s_V[0..5]}-ctrd-#{ctrd_V[0..2]}(github_SysNet4Admin)"]
      end
      cfg.vm.host_name = "cp-k8s"
      cfg.vm.network "private_network", ip: controller_IP
      cfg.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
      cfg.vm.synced_folder "../data", "/vagrant", disabled: true
      cfg.vm.synced_folder './helpers/', '/helpers/'
      cfg.vm.provision "shell", path: "k8s_env_build.sh", args: [ N, k8s_V[0..3], controller_IP ]
      cfg.vm.provision "shell", path: "k8s_pkg_cfg.sh", args: [ k8s_V, ctrd_V, "CP"]
      cfg.vm.provision "shell", path: "controlplane_node.sh", args: controller_IP
      config.vm.provision "shell", inline: <<-SHELL
          echo "root:123" | sudo chpasswd
      SHELL
    end

  #==============#
  # Worker Nodes #
  #==============#

  (1..N).each do |i|
    config.vm.define "w#{i}-k8s-#{k8s_V[0..5]}" do |cfg|
      cfg.vm.box = "sysnet4admin/Ubuntu-k8s"
      cfg.vm.provider "vmware_desktop" do |vb|
        vb.gui = true 
        vb.cpus = 1
        vb.memory = 1024
#        vb.vmx ["modifyvm", :id, "--groups", "/k8s-U#{k8s_V[0..5]}-ctrd-#{ctrd_V[0..2]}(github_SysNet4Admin)"]
      end
      cfg.vm.host_name = "w#{i}-k8s"
      cfg.vm.network "private_network", ip: "192.168.1.10#{i}"
      cfg.vm.network "forwarded_port", guest: 22, host: "6010#{i}", auto_correct: true, id: "ssh"
      cfg.vm.synced_folder "../data", "/vagrant", disabled: true
      cfg.vm.provision "shell", path: "k8s_env_build.sh", args: [ N, k8s_V[0..3], controller_IP ] 
      cfg.vm.provision "shell", path: "k8s_pkg_cfg.sh", args: [ k8s_V, ctrd_V, "W" ]
      cfg.vm.provision "shell", path: "worker_nodes.sh", args: controller_IP
    end
  end
end