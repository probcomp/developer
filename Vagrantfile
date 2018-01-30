Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = "probcomp"
  config.vm.network :private_network, ip: "192.168.0.42"
  config.vm.provider "virtualbox" do |v|
    v.name = "probcomp"
  end

  config.vm.synced_folder ".", "/home/vagrant/developer", :mount_options => ["dmode=777", "fmode=666"]
end
