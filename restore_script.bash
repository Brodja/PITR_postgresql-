#!/bin/bash
# =============== CONST ==============
PATH_TO_S3="/home/bohdan/fintest/" #s3main
PATH_TO_DB="/var/lib/postgresql/14/main/" #s3main
# =============== CONST END===========


# ============== FUNC =======================
function CHECK_PROCESS_DB_S { #1
	echo "Остановите БД выполнив: '/etc/init.d/postgresql stop'"
	echo "После остановки БД нажмите - ENTER"
	read ANSW_DB_STOP
	STATUS_DB_STOP=$(/etc/init.d/postgresql status)
	STATUS_ACTIVE="Active: active"
	if [[ "$STATUS_DB_STOP" == *"$STATUS_ACTIVE"* ]]; then
  		echo "БД не оставновлена!!!"
  		CHECK_PROCESS_DB_S
  	else 	
  		echo "БД оставновлена."
  		RENDER_LIST_BACKUPS #2
	fi
}

function RENDER_LIST_BACKUPS { #2
	echo "Список доступных бэкапов:"
	ls -c -1 $PATH_TO_S3
	BACKUPS_LIST=$(ls -c -1 $PATH_TO_S3)
	echo "Введите название из списка:"
	read BACKUP_NAME
	if [[ "$BACKUPS_LIST" == *"$BACKUP_NAME"* ]]; then
  		echo "Вы выбрали: $BACKUP_NAME."
  		CHECK_RM_MAIN #3
  	else 	
  		echo "Точки восстановления с именем - $BACKUP_NAME не существует!!!"
  		RENDER_LIST_BACKUPS
	fi
}

function CREATE_NEW_MAIN { #4
	echo 'Создание новой папки'
	sudo mkdir $PATH_TO_DB
	echo 'Расспаковка архива'
	sudo tar xf $PATH_TO_S3$BACKUP_NAME/*.tar.gz -C $PATH_TO_DB
	sudo chown postgres:postgres $PATH_TO_DB
    sudo chmod 700 $PATH_TO_DB
    echo 'Создание файлика'
    sudo touch $PATH_TO_DBrecovery.signal
    CHECK_EDIT_CONFIG #6
}

function CHECK_RM_MAIN { #3
	echo "Удалите БД: 'sudo rm -rf $PATH_TO_DB'"
	echo "После удаления БД нажмите - ENTER"
	read ANSW_DB_RM
	if ! [ -d $PATH_TO_DB ]; then
		echo 'Вы успешно удалили БД'
		CREATE_NEW_MAIN #4
	else
		echo 'БД существует'
		CHECK_RM_MAIN	
	fi
}
function CHECK_EDIT_CONFIG { #5
	RESTORE_COMMAND="gunzip <$PATH_TO_S3$BACKUP_NAME/%f> %p"
	PATH_TO_CONFIG="/etc/postgresql/14/main/postgresql.conf"

	ARCH_MODE=$(grep archive_mode $PATH_TO_CONFIG)
	ARR_ARCH_MODE=($ARCH_MODE)
	CHECK_ARR_ARCH_MODE=${ARR_ARCH_MODE[0]}

	ARCH_COMMAND=$(grep archive_command $PATH_TO_CONFIG)
	ARR_ARCH_COMMAND=($ARCH_COMMAND)
	CHECK_ARR_ARCH_COMMAND=${ARR_ARCH_COMMAND[0]}

	REST_COMMAND=$(grep restore_command $PATH_TO_CONFIG)
	ARR_REST_COMMAND=($REST_COMMAND)
	CHECK_ARR_REST_COMMAND=${ARR_REST_COMMAND[0]}

	if [[ "$CHECK_ARR_ARCH_MODE" != *"#"* ]]; then
  		echo "Закомментируйте строку 'archive_mode' - поставив '#' перед строкой"
	fi

	if [[ "$CHECK_ARR_ARCH_COMMAND" != *"#"* ]]; then
  		echo "Закомментируйте строку 'archive_command' - поставив '#' перед строкой"
	fi

	if [[ "$CHECK_ARR_REST_COMMAND" == *"#"* ]]; then
		echo "Раскомментируйте строку 'restore_command' - удалив '#' перед строкой"
	fi
	
	if [[ "$REST_COMMAND" != *"$RESTORE_COMMAND"* ]]; then
  		echo "Измените 'restore_command' на: '$RESTORE_COMMAND'"
	fi	

	if [[ "$CHECK_ARR_ARCH_MODE" != *"#"* || "$CHECK_ARR_ARCH_COMMAND" != *"#"*  || "$CHECK_ARR_REST_COMMAND" == *"#"*  ||  "$REST_COMMAND" != *"$RESTORE_COMMAND"* ]]; then
  		echo "После выполенения нажмите - ENTER"
		read COMPL
	else
		echo "Файл готов"
		CHECK_PROCESS_DB_A	
	fi

	if [[ "$CHECK_ARR_ARCH_MODE" != *"#"* || "$CHECK_ARR_ARCH_COMMAND" != *"#"*  || "$CHECK_ARR_REST_COMMAND" == *"#"*  ||  "$REST_COMMAND" != *"$RESTORE_COMMAND"* ]]; then
  		CHECK_EDIT_CONFIG
	fi
	
}

function CHECK_PROCESS_DB_A { #6
	echo "Запустите БД выполнив: '/etc/init.d/postgresql start'"
	echo "После запуска БД нажмите - ENTER"
	read ANSW_DB_STOP
	for ((i = 0; i < 10; i++))
	do	
		let count=10-$i
		echo $count
		sleep 1
	done
	
	STATUS_DB_ACTIVE=$(/etc/init.d/postgresql status)
	STATUS_ACTIVE="Active: active"
	if [[ "$STATUS_DB_ACTIVE" == *"$STATUS_ACTIVE"* ]]; then
  		echo "БД запущена."
  	else 	
  		echo "БД не запущена!!!."
  		CHECK_PROCESS_DB_A
	fi
}

# ============== FUNC END ====================

# ============== RUN =========================
CHECK_PROCESS_DB_S #1


echo "----------------------------------------------------------------------------------------"


