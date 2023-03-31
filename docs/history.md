# The history of Haiku's infrastructure

## Pre-2013 Old Days

(TODO) Fill in the *old* days

  * We used an awesome *free not for profits* account at Dreamhost.com.
  * They were awesome, however we began to grow rapidly and abuse Dreamhost's generosity.

## Jan 2013 - Nov 2018 Less Old Days

  * We got a dedicated server (baron) at Hetzner managed by Olta. It worked *really* well
    and was stable for multiple years. Maintenance was a massive time suck however. Multiple
    OpenSUSE VM's running various services, DMZ firewalls between hypervisor,host,and internet.
  * Network speeds outside of Germany were abysimal (100-200KB/s MAX) due to poor peering @ Hetzner.
  * Olta departed after many years of tireless hours of service.
  * Several of the OpenSUSE VM's were 32-bit, and we ran-into roadblocks performing basic updates to vm's
  * Everyone was afraid to touch anything given complexity, resulting in baron becoming *FAR* behind in OS upgrades.

## Nov 2018 - March 2019 Transition (bad) Days  (~$34 USD/mo)

  * waddlesplash replaced the old Drupal 6 for haiku-os.org with Hugo hosted at Netlify.
    * kallisti5 was against it, but he was completely wrong. Netlify saved our bacon.
  * When we finally did upgrade, a major OpenSUSE update failed on the hypervisor.
  * The OS + huge amounts of nightly images were lost in the software RAID.
  * kallisti5 installed CentOS 7 and began to rebuild using containers + Docker
  * kallisti5 found wasabi s3 storage which was cheap and moved all the nightly images there.
  * Things stableish (but slow at Hetzner)
  * A basic CentOS 7 update failed. We were unable to obtain KVM access from Hetzner for several hours.
    * kallisti5 rebooted after and hour of waiting in the unknown which resulted in the installation completely failing.
    * The failure here was stuffing the OS and all of our critical data under the Software RAID on two mirroed disks.
    * (The failure was also kallisti5 rebooting a machine which was upgrading in an unknown stage)
  * After a long outage, kallisti5 rushed critical stuff onto a scaleway.com VM
    * Transition of containers + persistant storage to a scaleway vm was *simple* and took like 45 minutes.
  * scaleway.com *sucked*.   Restarting VM's with large block attachments took *HOURS*
    * Spoilers: online.net is part of Scaleway.

## March 2019 - Aug 2019 Transition (meh) Days (~$84 USD/mo)

  * Purchased a dedicated server at online.net, with a online.net managed iSCSI.
  * Purchased premium support to get a 1Gbps private network.
  * OS is simple CentOS 7 + Docker on an SSD Software RAID.
  * All of our persistant data is on a remote iSCSI attachment over a dedicated 1Gbps private network.
  * Happy, Happy, Joy, Joy! Things are fast and easy to manage!
  * online.net's iSCSI starts getting *slow* at night (~8pm CST)
    * 120 MiB/s on a good day
    * Drops to 1MiB/s ~8pm CST daily.
    * online.net support unhelpful, wants to "turn our production server off to troubleshoot"
    * Ticket open for 3 months with no troubleshooting or resolution.
  * Huge iSCSI outage from online.net. Service unavailable for 10 hours.
    * Support unhelpful and suprised (pissed?) i was asking for updates every two hours when they haven't given me an update or ETA.
  * online.net restored service. Things came back up as expected.

## Aug 2019+ Digital Ocean (current) days (~$120 USD/mo)

  * Moved to a VM at DigitalOcean in Amsterdam (EU/GDPR)
  * Successfully moved to Docker Swarm
  * Using local SSD storage for persistant data, with a few block attachments for big things managed by rexray.
  * Speeds have been improved, system fairly stable

## Feb 2022 Digital Ocean managed Kubernetes (~$210.93 USD/mo)

  * Rexray project dead, substantial risk.  Migrate to k8s.
  * Rewrite Docker Swarm compose into Kubernetes workloads.
  * Shift to Traefik 2.x as our IngressController and Traefik CRD's only where needed
  * Deploy an isolated, traditional mail server vm so we can RPTR's
  * Moved to a three node managed Kubernetes cluster in Amsterdam (EU/GDPR)
  * Automatic encrypted backups via k8s CronJobs
    * Persistent volume backups to private S3 buckets via k8s CronJob
    * Database backups to private S3 buckets via k8s CronJob
	* Backup containers can also perform decryption + restores
  * Close to zero-downtime upgrades... however large shared RWO storage volumes for haikuports means we
    are unable to use plain deployments (we have to group things that use the same PV on the
    same physical k8s node)

## Mar 2023

  * Migrate containers from Docker (docker.io) to Github Container Registry (ghcr.io) due to
    announced end of Free team accounts.
