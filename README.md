# unison-linux-build

This is a simple docker container and script that builds a newer version of Unison than is available from apt-get or the Unison website.

Simply run `./build.sh` and you should get a tarball in the current directory with binaries for unison and unison-fsmonitor.

NOTE: The tarball contains the directories usr/local/bin, so you can extract this to a target linux system simply by running:

`
tar xzf <the built tarball> -C /
`
