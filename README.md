# PITR_postgresql-

CONFIG: /etc/postgresql/14/main/postgresql.conf
LOGS: /var/log/postgresql/postgresql-14-main.log
DB: /var/lib/postgresql/14/main


# ========================== НАСТРОЙКА АРХВИВАЦИИ! ====================================================

1. Создать папку для хранения бэкапов и дать права.
mkdir /home/$USER/$DIR/
sudo chown postgres:postgres /home/$USER/$DIR/
sudo chmod 777 /home/$USER/$DIR/

2. Закинуть скрипт для archive_command в папку: /var/lib/postgresql/14/main и дать прва на исполнение.
chmod +x /var/lib/postgresql/14/main/local_backup_script_new.sh

3. Остановить БД
/etc/init.d/postgresql stop

4. Отредактировать /etc/postgresql/14/main/postgresql.conf
#archive_mode = off    --->  archive_mode = on
#archive_command = ''  --->  archive_command = './local_backup_script.sh "%p" "%f"'

5. Отредактировать local_backup_script.sh 
PATH_TO_S3= -путь к папке созданой в первом шаге.
PERIOD_MS=  -период создания новой папки с бэкапом в мс.

6. Запустить БД
/etc/init.d/postgresql start

7. Тестирование
sudo -i -u postgres
psql
CREATE DATABASE test_db;
\c test_db
create table t1 (id int);
insert into t1 (id) values (99999990), (9999999);
insert into t1 select * from t1; x18 = 262144 записей, примерно файл в 16 МБ

create table t2 (id int);
insert into t2 select * from t1;



В логе /var/log/postgresql/postgresql-14-main.log наблюдать за процессом.


# ========================== РЕДАКТИРОВАНИЕ RESTORE! ====================================================
PATH_TO_S3= путь к папке с бэкапами
PATH_TO_DB= путь к папке с БД