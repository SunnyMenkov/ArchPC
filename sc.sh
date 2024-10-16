#!/bin/bash
cd $1

if ! [ $? -eq 0 ]; then
	echo "Ошибка пути"
	exit 1
fi

printf "Путь к папке - $1\nПользовательский процент - $2\nКоличество файлов для архивации - $3\n"

if [ -z "$1" ]; then
    echo "Путь не указан, завершение"
	exit 1
fi

if [ -z "$2" ]; then
    echo "Процент не указан, завершение"
	exit 1
fi

if [ -z "$3" ]; then
	echo "Не указано количество архивируемых файлов"
	exit 1
fi


if ! [[ "$2" =~ ^-?[0-9]+$ ]]; then
  
  echo "$2 не является целым числом."
  exit 1
fi

if [ "$2" -lt 0 -o "$2" -gt 100 ]; then
	echo "Выход за границы $2%"
	exit 1
fi

if [ "$3" -lt 0 ]; then
	echo "Отрицательное количество файлов"
	exit 1
fi

if ! [[ "$3" =~ ^-?[0-9]+$ ]]; then
  
  echo "$3 не является целым числом."
  exit 1
fi



echo "Mount"
echo "$3"
sudo dd if=/dev/zero of=file.img bs=1G count=1

mkfs.ext4 file.img

sudo mount -o loop file.img $1



cd $HOME

for i in {1..5}
do
	cd $1
	echo "Создание $i файла"
	sudo dd if=/dev/zero of=test$i.img bs=1M count=100

done

df -h


# Проверяем, что пользователь передал аргумент
if [ -z "$1" ]; then
  echo "Использование: $0 /путь/к/папке"
  exit 1
fi

# Путь к папке
DIR="$1"

# Получаем размер папки
DIR_SIZE=$(du -sb "$DIR" | cut -f1)

# Получаем доступное пространство на диске
AVAILABLE_SPACE=$(df "$DIR" | awk 'NR==2 {print $4}')

# Проверяем, что значения не пустые
if [ -z "$DIR_SIZE" ] || [ -z "$AVAILABLE_SPACE" ]; then
  echo "Не удалось получить информацию о размере или свободном пространстве."
  exit 1
fi

# Получаем общий размер диска
TOTAL_SPACE=$(df "$DIR" | awk 'NR==2 {print $2}')

# Рассчитываем процент заполненности
USAGE_PERCENT=$((100 * DIR_SIZE / 2000000000))

# Выводим результаты
echo "Папка: $DIR"
echo "Размер папки: $DIR_SIZE байт"
echo "Общий размер диска: $TOTAL_SPACE байт"
echo "Доступное пространство: $AVAILABLE_SPACE байт"
echo "Процент заполненности: $USAGE_PERCENT%"



cd $HOME


FILES_TO_ARCHIVE="$3"

if [ "$USAGE_PERCENT" -lt $2 ]; then

	echo "if we are here! $OLDPWD"

	cd $OLDPWD
	sudo mkdir backup
	cd backup
	#sudo tar -czvf archive.tar.bz2 $1
	find "$1" -type f -printf "%T@ %p\n" | sort -n | head -n "$FILES_TO_ARCHIVE" | cut -d' ' -f2 | sudo tar -czvf archive.tar.bz2 -T -
	
		if [ $? -eq 0 ]; then
    echo "Архив сделан, удаление файлов"
	
else
    echo "Ошибка архивации"
fi
	
	
	cd $1
	sudo rm -rf test*.img
	
	
	if [ $? -eq 0 ]; then
    echo "Удаление успешно"
else
    echo "Ошибка удаления"
fi
	
	

fi

exit 0