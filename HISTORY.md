# The history of Haiku's infrastructure

## Old Days

(TODO) Fill in the *old* days

  * We used an awesome *free not for profits* account at Dreamhost.com.
  * They were awesome, however we began to grow rapidly and abuse Dreamhost's generosity.

## Less Old Days

  * We got a dedicated server (baron) at Hetzner managed by Olta. It worked *really* well
    and was stable for multiple years. Maintenance was a massive time suck however. Multiple
    OpenSUSE VM's running various services, DMZ firewalls between hypervisor,host,and internet.
  * Network speeds outside of Germany were abysimal (100-200KB/s MAX) due to poor peering @ Hetzner.
  * Olta departed after many years of tireless hours of service.
  * Several of the OpenSUSE VM's were 32-bit, and we ran-into roadblocks performing basic updates to vm's
  * Everyone was afraid to touch anything, resulting in baron becoming *FAR* behind in OS upgrades.

## Transition (bad) Days  (~$34 USD/mo)

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

## Transition (meh) Days (~$84 USD/mo)

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
