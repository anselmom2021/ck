# Update the machine's packages
sudo apt update & sudo apt upgrade -y

# Reboot the machine to apply the new software
sudo reboot

# Identify and Instantiate the new disk
lsblk
sudo cgdisk /dev/sda

# Format the disk to be available for data
sudo mkfs -t ext4 /dev/sda1

# Get the disk UUID to insert it into fstab file
sudo blkid
sudo nano /etc/fstab  # Add something similar to this at the end of file: UUID="b4c93..."  /data  ext4  defaults  0  2

# Create the dir for the mountpoint
sudo mkdir /data

# Load all the mointpoints
sudo mount -av

# Add MongoDB Repo to the machine and prepare the installation
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb
sudo curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc |sudo gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg --dearmor
sudo echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

# Update the MongoDB package and their dependencies
sudo apt update

# Install MongoDB
sudo apt install mongodb-org

# Check if it's working
mongo --version

# Change MongoDB default DB location to the new volume/drive
mkdir /data/mongodb_data
nano /etc/mongod.conf  # Change the location parameter to the location created in the previous step
sudo chown -R mongodb:mongodb /data/mongodb_data/

# Start the DB Engine service and set it enable
sudo systemctl start mongod
sudo systemctl enable mongod

# Check the service status
sudo systemctl status mongod

