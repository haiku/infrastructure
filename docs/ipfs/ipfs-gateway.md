# Setting up a public IPFS Gateway

A quick run down of the steps needed to setup a gateway

## Requirements

* IPFS CLI installed to /usr/local/bin
* 80 GiB+ of storage
* 4 GiB+ of RAM
* 2+ vCPU

# Setup

**Install IPFS CLI**

(as root)

```
wget https://dist.ipfs.io/go-ipfs/v0.8.0/go-ipfs_v0.8.0_linux-amd64.tar.gz
tar -xvzf go-ipfs_v0.8.0_linux-amd64.tar.gz
cd go-ipfs
bash install.sh
```

**Setup IPFS Service**

(as root)

```
useradd -c "IPFS Service" -m -U ipfs
cat <<'EOF' > /etc/systemd/system/ipfs.service
[Unit]
Description=InterPlanetary File System (IPFS) daemon
Documentation=https://docs.ipfs.io/
After=network.target

[Service]
#LimitNOFILE=1000000
MemorySwapMax=0
TimeoutStartSec=infinity
Type=notify
User=ipfs
Group=ipfs
StateDirectory=ipfs
ExecStart=/usr/local/bin/ipfs daemon --init --migrate --enable-namesys-pubsub --enable-pubsub-experiment
Restart=on-failure
KillSignal=SIGINT

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable ipfs
```

**Setup IPFS Repo**

(as root)

```
su - ipfs
ipfs init --profile server
ipfs config show
```

* Make sure the gateway is listening on ```/ip4/127.0.0.1/tcp/8080```
* Make sure the StorageMax is set to a reasonable size (90% of available free space?)
  * This is the "cache", when full it will be garbage collected

**Setup IPFS Reverse Proxy**

> This enables https, and allows you to host hpkg.haiku-os.org on other domains
> without needing to setup special DNS records.
> Requests are reformed from rendering the native domain to rendering hpkg.haiku-os.org

* Install nginx
* Configure nginx

```
server {
        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;
        server_name de.hpkg.haiku-os.org; # managed by Certbot

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                proxy_pass http://localhost:8080;
                proxy_set_header Host hpkg.haiku-os.org;
                proxy_cache_bypass $http_upgrade;
                proxy_read_timeout 300;
                proxy_connect_timeout 300;
                proxy_send_timeout 300;
                # Correct ipns entry to accessed hostname
                sub_filter '<a href="//hpkg.haiku-os.org' '<a href="//$host';
                sub_filter_once off;
        }

        listen [::]:443 ssl ipv6only=on; # managed by Certbot
        listen 443 ssl; # managed by Certbot
        ssl_certificate /etc/letsencrypt/live/de.hpkg.haiku-os.org/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/de.hpkg.haiku-os.org/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
        if ($host = de.hpkg.haiku-os.org) {
                return 301 https://$host$request_uri;
        } # managed by Certbot

        listen 80 ;
        listen [::]:80 ;
        server_name de.hpkg.haiku-os.org;
        return 404; # managed by Certbot
}
```

**Speed up content discovery**

Configure a cron job run under the ipfs user, every 1 minute to ensure source nodes are in the pool of IPFS servers

> This is kind of a hack to try and improve network discovery of Haiku's data

```
#!/bin/bash

# Fill in trustIP and QUICK_HASH with information of known source IP
IP="trustIP"
QUIC_HASH="xxxyyyzzz"

IP_ESCAPE=$(echo $IP | sed 's/\./\\\\./g')
NODES=$(ipfs swarm addrs | grep "$IP_ESCAPE" | wc -l)
if [[ $NODES -lt 2 ]]; then
        echo "Reconnecting to $IP..."
        ipfs swarm connect /ip4/$IP/udp/4001/quic/p2p/$QUIC_HASH
fi
```
