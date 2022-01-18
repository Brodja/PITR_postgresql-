# =========== S3
1. На S3 создать корзину
2. На AWS создать пользователя:  IAM -> Users
3. В права нужно добавить пункт “AmazonS3FullAccess”
4. В конце создания будут ключики, например: AАВАA2ВЫАААВЫАЫВA2ZFFPG:COf48+HВАb9564Mcc1ВАВАЫ1SYW0qjUTrk7j
# Это сохранить для дальнейших действий.
5. sudo apt install s3fs

# У меня ${HOME}/.passwd-s3fs - работал для создания маунта сейчас
# /etc/passwd-s3fs - работал для создания маунта при старте системы

6. /etc/passwd-s3fs | ${HOME}/.passwd-s3fs - создать и в ставить ид:ключ (выше сохраняли)
7. chmod 600 /etc/passwd-s3fs | chmod 600  ${HOME}/.passwd-s3fs
8. Для маунта при запуске у файл /etc/fstab дописать строку: 
# Без кавычек "s3fs#mybuckettestwork путь/к/папке fuse _netdev,allow_other,passwd_file=/etc/passwd-s3fs 0 0"

# пример:
#         s3fs#mybuckettestwork /home/bohdan/s3dir fuse _netdev,allow_other,passwd_file=/etc/passwd-s3fs 0 0

# Для текущего маунта выполнить в терминале: 
#         s3fs mybuckettestwork /home/bohdan/s3dir -o passwd_file=/etc/passwd-s3fs -o allow_other