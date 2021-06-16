# Haiku IPFS mirroring quick start

This guide serves as a quickstart to mirroring [Haiku's releases and repositories](https://gateway.ipfs.io/ipns/hpkg.haiku-os.org) on [IPFS](https://ipfs.io).

> Essentially, you will be "seeding" Haiku packages / artifacts in Bittorrent speak. (IPFS is *not* Bittorrent, just the same concept)

## Requirements

* A computer with at least 4 GiB of RAM running Linux, MacOS, Windows
  * A Raspberry Pi 4 works just fine as well :-)
* An internet connection (dynamic or static ip)
* Ability to accept incoming connections on tcp port 4001
  * Incoming requests to your router on tcp port 4001 should be forwarded to the system where IPFS is running.
  * https://www.lifewire.com/how-to-port-forward-4163829
* 250 GiB of free disk space

## Process (IPFS Desktop)

1. [Install the IPFS Desktop application](https://docs.ipfs.io/install/ipfs-desktop/)
2. Once IPFS desktop is started, click *SETTINGS*
3. Under *IPFS Config* find ```StorageMax```. Change from 10GB to 250GB (or more)
   1. This is important and prevents needing to re-download data if your pin fails
4. Click *save*
5. Exit IPFS Desktop, and start it again.
6. Click *FILES* -> *Import* -> *From IPFS*
7. Enter /ipns/hpkg.haiku-os.org

> Be sure to occasionally follow steps 6 and 7 to pull the latest updates.

## Process (IPFS CLI)

1. [Install the IPFS CLI](https://docs.ipfs.io/how-to/command-line-quick-start/)
2. Be sure to Initialize the repository, and start the IPFS daemon (ensure you don't provide the --enable-gc flag)
3. Run ```ipfs pin --progress /ipns/hpkg.haiku-os.org```
4. This command will take some time. Be paitent

> Be sure to occasionally follow step 4 to pull the latest updates. Nightly or weekly is best.
