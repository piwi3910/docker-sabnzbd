#!/bin/bash
set -e

#
# Display settings on standard out.
#

USER="sabnzbd"

echo "SABnzbd settings"
echo "================"
echo
echo "  User:       ${USER}"
echo "  UID:        ${SABNZBD_UID:=666}"
echo "  GID:        ${SABNZBD_GID:=666}"
echo "  GID_LIST:   ${SABNZBD_GID_LIST:=}"
echo
echo "  Config:     ${CONFIG:=/datadir/config.ini}"
echo

#
# Change UID / GID of SABnzbd user.
#

printf "Updating UID / GID... "
[[ $(id -u ${USER}) == ${SABNZBD_UID} ]] || usermod  -o -u ${SABNZBD_UID} ${USER}
[[ $(id -g ${USER}) == ${SABNZBD_GID} ]] || groupmod -o -g ${SABNZBD_GID} ${USER}
echo "[DONE]"

#
# Create groups from SABNZBD_GID_LIST.
#
if [[ -n ${SABNZBD_GID_LIST} ]]; then
    for gid in $(echo ${SABNZBD_GID_LIST} | sed "s/,/ /g")
    do
        printf "Create group $gid and add user ${USER}..."
        groupadd -g $gid "grp_$gid"
        usermod -aG grp_$gid ${USER}
        echo "[DONE]"
    done
fi

#
# Set directory permissions.
#

printf "Set permissions... "
chown -R ${USER}: /sabnzbd
function check_permissions {
  [ "$(stat -c '%u %g' $1)" == "${SABNZBD_UID} ${SABNZBD_GID}" ] || chown ${USER}: $1
}
check_permissions /datadir
check_permissions /media
check_permissions $(dirname ${CONFIG})
if [ -f "${CONFIG}" ]; then
    check_permissions $CONFIG
fi    
echo "[DONE]"

#
# Check if the config file already exists, if not start sabnzbd to generate one, and then shut off,
# so we can adapt the config else skip
#

if [ ! -f "${CONFIG}" ]; then 
    echo "Pre-Starting SABnzbd to generate config file"
    touch ${CONFIG}
    check_permissions $CONFIG
    exec su -pc "./SABnzbd.py -b 0 -f ${CONFIG} ${LISTENER}" ${USER} &
    sleep 10
    killall SABnzbd.py
    while pgrep SABnzbd.py >/dev/null; do
        echo "shutting down !!!"
        sleep 1
    done
    echo "sabnzbd shutdown"
fi 

#
# Because SABnzbd runs in a container we've to make sure we've a proper
# listener on 0.0.0.0. We also have to deal with the port which by default is
# 8080 but can be changed by the user.
#

printf "Get listener port... "
PORT=$(sed -n '/^port *=/{s/port *= *//p;q}' ${CONFIG})
LISTENER="-s 0.0.0.0:${PORT:=8080}"
echo "[${PORT}]"

#
# Update the host_whitelist setting (see https://sabnzbd.org/hostname-check)
# with any additional hostname/fqdn entries supplied via the HOST_WHITELIST_ENTRIES
# env variable.
#

if [[ -n ${HOST_WHITELIST_ENTRIES} ]];
then
    printf "Updating host_whitelist setting ... "
    sed -i -e "s/^host_whitelist *=.*$/host_whitelist = ${HOSTNAME}, ${HOST_WHITELIST_ENTRIES}/g" ${CONFIG}
    HOST_WHITELIST=$(sed -n '/^host_whitelist *=/{s/host_whitelist *= *//p;q}' ${CONFIG})
    echo "[${HOST_WHITELIST}]"
fi


#
# Finally, start SABnzbd.
#

echo "Starting SABnzbd..."
exec su -pc "./SABnzbd.py -b 0 -f ${CONFIG} ${LISTENER}" ${USER}
