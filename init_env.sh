# check vagrant setting
ExistVagrant=$(dpkg -l | grep vagrant | wc -l)
if [ ! $ExistVagrant ]; then
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg;
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list;
sudo apt update && sudo apt install vagrant;
fi;

# check virtual box setting
ExistVB=$(dpkg -l | grep virtualbox | wc -l)
if [ ! $ExistVB ]; then
UbuntuVersion=$(lsb_release -c | awk '{print $2}');
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $UbuntuVersion contrib" | sudo tee /etc/apt/sources.list.d/virtualBox.list > /dev/null;
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg;
sudo apt update && apt install virtualbox-6.1;
fi;

vagrant up
vagrant ssh