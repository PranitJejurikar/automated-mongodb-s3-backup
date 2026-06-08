#!/bin/bash

BACKUP_DIR="/tmp/mongodb_backups"
TIMESTAMP=$(date +%F-%H%M%S)
S3_BUCKET="s3://mongodb-backups-2026"
LOG_FILE="/var/log/mongodb_backup.log"

mkdir -p $BACKUP_DIR

echo "[$(date)] Starting MongoDB automated backup routine..." >> $LOG_FILE

mongodump --archive=$BACKUP_DIR/mongo-db-$TIMESTAMP.archive.gz --gzip

if aws s3 cp $BACKUP_DIR/mongo-db-$TIMESTAMP.archive.gz $S3_BUCKET/backups/mongo-db-$TIMESTAMP.archive.gz >> $LOG_FILE 2>&1; then
    echo "[$(date)] SUCCESS: Backup uploaded securely to S3." >> $LOG_FILE
else
    echo "[$(date)] ERROR: S3 transfer failed. Review details above." >> $LOG_FILE
fi

rm -f $BACKUP_DIR/mongo-db-$TIMESTAMP.archive.gz
echo "[$(date)] Local cleanup finished." >> $LOG_FILE
