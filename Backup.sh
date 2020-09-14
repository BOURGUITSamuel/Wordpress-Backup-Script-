#!/bin/bash

#### Settings ####
NOW=$(date +"%Y-%m-%d-%H%M")
BACKUP_FOLDER=/backup/

#### Site-specific Info ####
SITE_PATH="/var/www/html/wordpress/" #Could also be subsites/subsitename
SITE_CONF="/etc/apache2/sites-available/" #virtual_host apache config
DB_NAME=`cat /var/www/html/wordpress/wp-config.php | grep DB_NAME | cut -d \' -f 4`
DB_USER=`cat /var/www/html/wordpress/wp-config.php | grep DB_USER | cut -d \' -f 4`
DB_PASS=`cat /var/www/html/wordpress/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
DB_HOST=`cat /var/www/html/wordpress/wp-config.php | grep DB_HOST | cut -d \' -f 4`

#### Retention ####
RETENTION=7

#### Files backup ####
function files_backup {
sudo tar -cvf $BACKUP_FOLDER$NOW.tar.gz $SITE_PATH $SITE_CONF 
}

#### Database Backup ####
function database_backup {
sudo mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME > $DB_NAME.$NOW.sql
sudo mv $DB_NAME.$NOW.sql $BACKUP_FOLDER/$DB_NAME.$NOW.sql
}

#### Scp Transfert ####
function scp_transfert {
sudo scp $BACKUP_FOLDER$NOW.tar.gz root@ftpserver:/backup/
sudo scp $BACKUP_FOLDER$DB_NAME.$NOW.sql root@ftpserver:/backup/
}

#### Delete old data with retention option ####
function retention {	
sudo ssh root@ftpserver "find /backup/ -mtime +$RETENTION -delete"
}

#### Runner Class ####
files_backup
database_backup
scp_transfert
retention
