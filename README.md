## About

This is a Docker image for [SABnzbd](http://sabnzbd.org/) - the Open Source Binary Newsreader written in Python.
More inportantly this is an `ARM64` build -> ready to run on your raspberry pi with ubuntu.
This also adds support to set the host whitelist on first boot, this allows me to get it to run on `kubernetes` or `k8s` with nginx as ingress.

The Docker image currently supports:

* running SABnzbd under its __own user__ (not `root`)
* changing of the __UID and GID__ for the SABnzbd user
* changing the `host_whitelist` setting for compatibility with [hostname verification](https://sabnzbd.org/hostname-check)
* support for OpenSSL / HTTPS encryption
* support for __RAR archives__
* support for __ZIP archives__
* support for __7Zip archives__ ([with SABnzbd version >= 0.8](#improvements-for-sabnzbd-version--08))
* support for the latest `par2` repair utility ([improved with SABnzbd version >= 0.8](#improvements-for-sabnzbd-version--08))

## Run

* There will always be two tags available: Latest and a specific version.
* The version matches the sabnzbd [releases](https://github.com/sabnzbd/sabnzbd/releases)
* versions get rebuild weekly to include any updates to ubuntu or a newer release


### Run via Docker CLI client

To run the SABnzbd container you can execute:

```bash
docker run --name sabnzbd -v <datadir path>:/datadir -v <media path>:/media -p 8080:8080 sabnzbd/sabnzbd
```

Open a browser and point it to [http://my-docker-host:8080](http://my-docker-host:8080)

### Hostname verification and updating `host_whitelist`

Starting with version 2.3.3 SABnzbd implements [hostname verification](https://sabnzbd.org/hostname-check)
to protect against DNS hijacking attacks. Thus by default SABnzbd allows access
to the web interface only by either accessing it directly by IP address or by
the hostname of the machine on which it runs. But the IP address or hostname of
the running Docker instance is not always available or accessible from the
outside (especially when running in Kubernetes).

You can work around this by setting the container hostname with
`docker create -h sabnzbd.example.com ...` when creating the container. This
will allow you to access SABnzbd by `http://sabnzbd.example.com:8080` by
default.

You can also use set the environment variable `HOST_WHITELIST_ENTRIES` to a
string of comma-separated values of hostnames and FQDNs under which SABnzbd
should be accessible. This will update the [`host_whitelist` special setting](https://sabnzbd.org/wiki/configuration/2.3/special)
with those values. Note that the container's hostname is always included in
this whitelist. For example:

```
HOST_WHITELIST_ENTRIES="sabnzbd.example.com, sabnzbd.other.example.net"
```
