## Deploying Concourse Workers

"Containers"

### Requirements

  * Worker running Linux (I used Fedora)
    * Use any Linux you like, but make *sure* it has a *recent* kernel and has containerd / runc
  * 4 GiB or more memory
  * NVMe Storage is nice for the Concourse work directory.

### Setup

  * Download the latest concourse, extract to /opt/
    https://github.com/concourse/concourse/releases/
  * Write out the settings to /opt/concourse/worker.env
    ```
    CONCOURSE_WORK_DIR=/opt/concourse/worker
    CONCOURSE_TSA_WORKER_PRIVATE_KEY=/opt/concourse/worker_key
    CONCOURSE_TSA_PUBLIC_KEY=/opt/concourse/tsa_host_key.pub
    CONCOURSE_TSA_HOST=ci.haiku-os.org:8022
    CONCOURSE_BAGGAGECLAIM_DRIVER=btrfs
    CONCOURSE_BIND_PORT=7777
    CONCOURSE_BIND_IP=127.0.0.1
    ```
    CONCOURSE_WORK_DIR is a path with at least ~50 GB (builds happen here)

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
    MemoryLimit=infinity
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
    /opt/concourse/bin/concourse generate-key -f /opt/concourse/worker_key
  * Place concourse public key at:
    /opt/concourse/tsa_host_key.pub
  * Add worker public key to concourse server.
  
  * systemctl daemon-reload
  * systemctl enable concourse
  * systemctl start concourse
