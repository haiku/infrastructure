## Deploying Concourse Workers

"Containers"

### Requirements

  * Worker running Debian 12+
    * Debian is recommended as it is the tested platform
    * Ubuntu may be functional, but historically has been problematic
    * RHEL or RHEL Clones no longer support the required btrfs filesystem. Their loss.
  * 4 GiB or more memory
  * Minimum OS install separate partition / filesystem for Concourse work directory.
    * Two disks (One for OS, one NVMe for builds) is "nice" but not required.
    * 16 GiB (or more) for OS (ext4 preferred)
    * Concourse Work Directory (/opt/concourse/worker)
      * 100 GiB (or more) of disk space
      * BTRFS formatted
      * NVMe Storage is preferred

### Debian Setup

  * Install a minimal Debian 12 system with SSH running. GUI not needed
  * Hostname hbXX01  (where XX are your initials, this is what people see for the builder)
  * Install the pre-requirements
    ```
    apt install btrfs-progs sudo vim iptables
    mkdir -p /opt/concourse/worker
    ```
  * Add your btrfs partition to /etc/fstab (be sure to adjust the disk):
    ```
    echo '/dev/nvme0n1p1 /opt/concourse/worker btrfs defaults,noatime,compress=zstd 0 0' >> /etc/fstab
    mount -a
    ```
  * Download the latest concourse matching our server version, extract to /opt/
    https://github.com/concourse/concourse/releases/
  * Write out the settings to /opt/concourse/worker.env
    ```
    CONCOURSE_WORK_DIR=/opt/concourse/worker
    CONCOURSE_TSA_WORKER_PRIVATE_KEY=/opt/concourse/worker_key
    CONCOURSE_TSA_PUBLIC_KEY=/opt/concourse/tsa_host_key.pub
    CONCOURSE_TSA_HOST=ci.haiku-os.org:8022
    CONCOURSE_BAGGAGECLAIM_DRIVER=btrfs
    CONCOURSE_BIND_IP=127.0.0.1
    CONCOURSE_BIND_PORT=7777
    # If you want to use containerd (recommended)
    CONCOURSE_RUNTIME=containerd
    CONCOURSE_CONTAINERD_DNS_SERVER=1.1.1.1
    CONCOURSE_CONTAINERD_DNS_PROXY_ENABLE=false
    # If you want to use the older garden
    #CONCOURSE_RUNTIME=garden
    #CONCOURSE_GARDEN_ALLOW_HOST_ACCESS=true
    #CONCOURSE_GARDEN_DNS_SERVER=1.1.1.1
    #CONCOURSE_GARDEN_DNS_PROXY_ENABLE=false
    ```
  * The ```_DNS_SERVER=``` entries above solve an invalid resolv.conf within containers. This cause
    is some linux distros are set to nameserver 127.0.0.1 for caching (which is invalid within a
    container).  Essentually you're telling the containers which nameserver to use in their resolv.conf

  * ```CONCOURSE_WORK_DIR``` is a path to a btrfs filesystem with at least ~100 GB (builds happen here).
  * ```BAGGAGECLAIM_DRIVER=btrfs``` means it's expected that ```CONCOURSE_WORK_DIR``` is btrfs formatted.

  * Write out the systemd service to /usr/lib/systemd/system/concourse.service
    ```
    [Unit]
    Description=Concourse CI worker process
    After=network.target
    
    [Service]
    EnvironmentFile=/opt/concourse/worker.env
    ExecStart=/opt/concourse/bin/concourse worker
    KillMode=process
    LimitNPROC=infinity
    LimitNOFILE=infinity
    MemoryMax=infinity
    TasksMax=infinity
    Restart=on-failure
    RestartSec=10
    ExecStop=/bin/kill -USR2 $MAINPID ; /usr/bin/tail --pid $MAINPID -f /dev/null
    TimeoutStopSec=30
    User=root
    Group=root
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=concourse_worker
    Delegate=yes
    
    [Install]
    WantedBy=multi-user.target
    ```

  * Generate worker private key:
    ```/opt/concourse/bin/concourse generate-key -t ssh -f /opt/concourse/worker_key```
    * Add worker public key (/opt/concourse/worker_key.pub) to concourse server.
  * Get the public key from the concourse server:
    ```ssh-keyscan -t ssh-rsa -p 8022  ci.haiku-os.org```
    * Place concourse public key from the concourse server on the worker at:
      ```/opt/concourse/tsa_host_key.pub```
  
  * ```systemctl daemon-reload```
  * ```systemctl enable concourse```
  * ```systemctl start concourse```

### Common Problems

#### garden based containers can't mount cgroup to rootfs

**Problem**

The older (and default) container engine is written for an old cgroupsv1 world which causes
this error. Modern kernels have moved onto cgroupsv2

> mounting \"cgroup\" to rootfs at \"/sys/fs/cgroup\" caused: invalid argument"

**Solution**

A [bug report](https://github.com/concourse/concourse/issues/8675) references this
and highlights a solution of adding ```systemd.unified_cgroup_hierarchy=false``` to your kernel
boot flags (edit /etc/default/grub; update-grub).   This is a hack however, and may impact
systemd functionality.

Using the systemd backend is recommended as it is more modern and supported

#### systemd based containers can't access the internet

**Problem**

This is an issue we ran into on an Ubuntu 22.x builder.  The cause was never found.

**Solution**

We reverted to the older garden-based backend which appeared to result in functional builds
when paired with "garden based containers can't mount cgroup to rootfs" solution above.
