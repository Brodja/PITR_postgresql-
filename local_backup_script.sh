#!/bin/bash
# =============== CONST ==============
PATH_TO_S3="/home/bohdan/fintest/" #s3main
FIND_MOD_TIME="-cmin -7" #-mtime -7 
PATH_LAST_DIR=$(find $PATH_TO_S3 -type d $FIND_MOD_TIME -name "*-*-*" | tail -1)
CHECK_LENGTH_LAST_DIR=$(find $PATH_TO_S3 -type d $FIND_MOD_TIME -name "*-*-*" | tail -1 | wc -l)
NEW_DIR_MARK=$(date +"%m/%d/%Y %H:%M:%S")
NEW_DIR_NAME=`echo $NEW_DIR_MARK | sed 's/\//-/g' | sed 's/ /_/g'`
VARIABLE_p=$1
VARIABLE_f=$2
PERIOD_MS=300000

week_ms=604800000
# =============== CONST END===========

# +++++++++++++++++++ LOGS ++++++++++++++++
echo "PATH TO LAST DIR: $PATH_LAST_DIR"
echo "EXIST LAST DIR: $CHECK_LENGTH_LAST_DIR"
# +++++++++++++++++++ LOGS END+++++++++++++


# ============== FUNC =======================
function GET_DB_ZIP {
	echo "********* START ARCHIVING ******"
	pg_basebackup -D $PATH_TO_S3$LAST_DIR_NAME/backup-box
	tar -C $PATH_TO_S3$LAST_DIR_NAME/backup-box -czf $PATH_TO_S3$LAST_DIR_NAME/backup-$(date +%Y-%m-%d).tar.gz .
	rm -rf $PATH_TO_S3$LAST_DIR_NAME/backup-box
	echo "********* FINISHED ARCHIVING ******"
}

function CREATE_DIR {
	echo "------- START CREATING DIR -------- dir name: $NEW_DIR_NAME"

	LAST_DIR_NAME=$NEW_DIR_NAME
	mkdir $PATH_TO_S3$NEW_DIR_NAME
	mkdir $PATH_TO_S3$NEW_DIR_NAME/backup-box
	chmod 777 $PATH_TO_S3$NEW_DIR_NAME
	chmod 777 $PATH_TO_S3$NEW_DIR_NAME/backup-box

	echo "---------- NEW DIR CREATED ----------"
	GET_DB_ZIP
}

function CHECK_DIR_DATE {
	NAME_TO_DATE=`echo $LAST_DIR_NAME | sed 's/-/\//g' | sed 's/_/ /g'`
	echo " DATE LAST DIR: $NAME_TO_DATE"
	let DATE_MS_LAST_DIR=$(date -d "$NAME_TO_DATE" +"%s")*1000
	let DATE_MS_NOW=$(date +%s)*1000
	echo "DATE_MS_LAST_DIR = $DATE_MS_LAST_DIR"
	echo " DATE_MS_NOW = $DATE_MS_NOW"
	let DIFFERENCE=$DATE_MS_NOW-$DATE_MS_LAST_DIR
	if (($DIFFERENCE > $PERIOD_MS));then
		echo "NEED NEW DIR"
		CREATE_DIR
	else
		echo "Ok"
	fi
}

function SAVE_AND_ZIP_WAL {

	gzip < $VARIABLE_p > $PATH_TO_S3$LAST_DIR_NAME/$VARIABLE_f
}

# ============== FUNC END ====================

# ============== RUN =========================

if [ $CHECK_LENGTH_LAST_DIR -eq 0 ]; then
	echo "DIR NOT EXIST"
	CREATE_DIR
else
	LAST_DIR_NAME=${PATH_LAST_DIR:${#PATH_TO_S3}}
	echo "DIR EXIST AND I NEET TO CHECK DATE DIR: $LAST_DIR_NAME"
	CHECK_DIR_DATE
fi

SAVE_AND_ZIP_WAL	

echo "----------------------------------------------------------------------------------------"