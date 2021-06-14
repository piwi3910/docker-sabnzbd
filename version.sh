echo "Finding latest Sabnzbd release and set it as a env.variable to use during docher build"
apt update -y
apt install curl grep -y
version=$(curl --silent "https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
echo "version=$version" >> vars.env

