#!/bin/bash
echo "Finding latest Sabnzbd release and set it as a env.variable to use during docher build"

version=$(curl --silent "https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
