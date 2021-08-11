curl --silent "https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'


