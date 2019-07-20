#!/bin/bash
VERSION="5.4.0"

echo "Ensure this is enabled:"
cat /boot/config-$(uname -r) | grep CONFIG_USER_NS

yum refresh
yum install -y wget dnf-plugins-core containerd.io
yum update -y

systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld

wget https://github.com/concourse/concourse/releases/download/v${VERSION}/concourse-${VERSION}-linux-amd64.tgz -O /tmp/concourse-${VERSION}-linux-amd64.tgz

cd /opt
tar xvf /tmp/concourse-${VERSION}-linux-amd64.tgz

cat > /opt/concourse/worker.env <<-EOF
CONCOURSE_WORK_DIR=/opt/concourse/worker
CONCOURSE_TSA_WORKER_PRIVATE_KEY=/opt/concourse/worker_key
CONCOURSE_TSA_PUBLIC_KEY=/opt/concourse/tsa_host_key.pub
CONCOURSE_TSA_HOST=ci.haiku-os.org:8022
EOF

cat > /opt/concourse/tsa_host_key.pub <<-EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB15Zeiq7qqS/VDarUS99LypcwixgCCVmLUj5kCNGWCvUIS4SLBTA1AdNg/Xhz1yLMtGHqVIxLVGQE+iOkSrlqhtsqOxx0mKW2IgGB0cqMbmRUfsodYFef7mQI9WxwdYkbgfIEjY4OBkRdoYsIycpj/SWLQjEChFIc1E4M39onvXFPQskgIjdWIoZpSRg2i6Y7an098fQJaQNr3YrDDaoRtJIhpt+2BhdsKg1U0YNwicUX748LljRGa9njqtFQp4hX3AlrF2yc7gsQ5rBzuclyLIz9BSkGEBhrjgGHfCHXpCGZO84Ry0DqUj1E7v6yMF+9yylkKbb7+k1sYSo6WIjWE8Bz7taaSTMNLzS7mtZVl2q/T6iUc904cpsGXvZLfM8m3i2g6eyASW58VzRjpYfQNULWhVpIL5U+70EW5UOwiwCekRYqzyIv3fd13vlTQMvBVMHzmcR0LDEts5+9QgMxJnUHy+/I+FRXGvWjHlk2DpNj1AI9f/TNlyBAt7w1kq+7PhCccRO+EDmPlUohxbQvXiMYZph0qr5quZH3zR0VmG0o7fP3RKAiVzy9XvZAeKcfn9MfLwKAIQsKLCYJWLGcahvAqGYtpDxAcks6l+4m1sOCdpXFmMAB4+iyihe03NSrst67Ql+9E4crcx3kues+kmCW9gIkS+CdKUahgiyKgw==
EOF

cat >  /usr/lib/systemd/system/concourse.service <<-EOF
[Unit]
Description=Concourse CI worker process
After=network.target

[Service]
EnvironmentFile=/opt/concourse/worker.env
ExecStart=/opt/concourse/bin/concourse worker
KillMode=process
LimitNPROC=infinity
LimitNOFILE=infinity
TasksMax=infinity
Restart=on-failure
RestartSec=3
ExecStop=/bin/kill -USR2 $MAINPID ; /usr/bin/tail --pid $MAINPID -f /dev/null
TimeoutStopSec=300
User=root
Group=root
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=concourse_worker
Delegate=yes

[Install]
WantedBy=multi-user.target
EOF

if [ ! -f /opt/concourse/worker_key ]; then
	echo "Generating worker key..."
	/opt/concourse/bin/concourse generate-key -t ssh -f /opt/concourse/worker_key

	echo "Put this key onto the concourse server:"
	echo "-----%<-----%<-----------%<-------------%<"
	cat /opt/concourse/worker_key.pub
	echo "-----%<-----%<-----------%<-------------%<"
fi

systemctl daemon-reload
systemctl stop concourse
systemctl start concourse
systemctl enable concourse
