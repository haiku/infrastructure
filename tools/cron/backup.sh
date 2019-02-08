#!/bin/bash

DATE=$(date +%m%d%y)
TARGETS="infrastructure_buildbot_config infrastructure_discourse_shared infrastructure_discourse_logs infrastructure_fathom_secrets infrastructure_gerrit_data infrastructure_grafana_data infrastructure_hds_secrets infrastructure_minio_config infrastructure_pootle_data infrastructure_postgres_data infrastructure_prometheus_data infrastructure_redis_data infrastructure_s3_secrets infrastructure_smtp_keys infrastructure_trac_data infrastructure_traefik_acme infrastructure_userguide_data"
TOTAL=0
OUTPUT="/var/backups"

ZIPPASS=$(cat /root/.secret)

# Every day of week, update backup-latest
for i in $TARGETS; do
	SIZE=$(du -s /var/lib/docker/volumes/$i | awk ' { print $1 } ')
	TOTAL=$(expr $TOTAL + $SIZE)
	7za u -up0q3r2x2y2z1w2 -t7z -p$ZIPPASS -mx=1 $OUTPUT/backup-latest-${i}.7z /var/lib/docker/volumes/$i
done

# Every Sunday, 'archive' the backup-latest and start again.
# Also delete archives over 30 days old
if [[ $(date +"%u") -eq 7 ]]; then
	for i in $TARGETS; do
		mv $OUTPUT/backup-latest-${i}.7z  $OUTPUT/backup-$DATE-${i}.7z
		echo "Cleaning up over 15 days..."
		find $OUTPUT -mtime +15 | xargs rm
	done
fi
