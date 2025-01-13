#!/bin/bash

# Директории
SOURCE_DIR=~
DEST_DIR=/tmp/backup

# Выполняем резервное копирование
rsync -av --exclude='.*' --checksum "$SOURCE_DIR/" "$DEST_DIR/"

# Проверка успешности выполнения
if [ $? -eq 0 ]; then
    echo "$(date): Backup successful" >> /var/log/backup.log
else
    echo "$(date): Backup failed" >> /var/log/backup.log
fi
