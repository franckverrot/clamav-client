# Update Ubuntu and install ClamAV
apt-get update
apt-get install clamav-daemon clamav-freshclam clamav-unofficial-sigs

# Update the signature database and start the daemon
freshclam
service clamav-daemon start
