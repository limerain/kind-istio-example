ENV["LC_ALL"] = "en_US.UTF-8"
ENV["TZ"] = "Asia/Seoul"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false

    vb.cpus = "4"
    vb.memory = "4096"
  end

  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 5173, host: 5173

  config.vm.network "public_network"
  config.vm.boot_timeout = 300

  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".vagrant/", rsync__auto: false

  config.vm.provision "shell", inline: <<-SHELL
    cd /vagrant/src
    chmod +x install.sh
    sudo ./install.sh
  SHELL
end
