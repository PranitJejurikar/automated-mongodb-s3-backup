#!/bin/bash

# --- CONFIGURATION ---
BACKUP_DIR="/tmp/mongodb_backups"
TIMESTAMP=$(date +%F-%H%M%S)
S3_BUCKET="s3://my-mongo-backup-bucket-2026"
LOG_FILE="/var/log/mongodb_backup.log"
# ---------------------

# Ensure local backup directory exists
mkdir -p $BACKUP_DIR

echo "[$(date)] Starting MongoDB automated backup routine..." >> $LOG_FILE

# 1. Take a snapshot of the database and zip it up
mongodump --archive=$BACKUP_DIR/mongo-db-$TIMESTAMP.archive.gz --gzip

# 2. Upload the compressed archive directly to your S3 bucket
if aws s3 cp $BACKUP_DIR/mongo-db-$TIMESTAMP.archive.gz $S3_BUCKET/backups/mongo-db-$TIMESTAMP.archive.gz >> $LOG_FILE 2>&1; then
    echo "[$(date)] SUCCESS: Backup uploaded securely to S3." >> $LOG_FILE
else
    echo "[$(date)] ERROR: S3 transfer failed. Review details above." >> $LOG_FILE
fi

# 3. Clean up the local file so your EC2 server doesn't run out of storage space
rm -f $BACKUP_DIR/mongo-db-$TIMESTAMP.archive.gz
echo "[$(date)] Local cleanup finished." >> $LOG_FILE
echo "----------------------------------------" >> $LOG_FILE
