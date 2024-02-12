Vagrant-стенд c PAM

Цель домашнего задания
Научиться создавать пользователей и добавлять им ограничения

Описание домашнего задания
1) Запретить всем пользователям, кроме группы admin, логин в выходные (суббота и воскресенье), без учета праздников
* дать конкретному пользователю права работать с докером
и возможность рестартить докер сервис

Команды:
1 [root@pam ~] sudo useradd otusadm && sudo useradd otus
#  Добавляем пользователей на виртуальной машине pam    
2 [root@pam ~] echo "Otus2022" | sudo passwd --stdin otusadm && echo "Otus2022" | sudo passwd --stdin otus
# Задаем пароли вновь созданным пользователям
3 [root@pam ~] sudo groupadd -f admin
# Создаем группу admin
4 [root@pam ~] usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin
# Добавляем пользователей в группу admin
5 [root@pam ~] cat /etc/group | grep admin
# Проверяем членство в группе admin
6 [root@pam ~] vi /usr/local/bin/login.sh
# Создал скрипт для проверки доступа к хосту pam для пользователей в зависимости от дня недели
7 [root@pam ~] chmod +x /usr/local/bin/login.sh
# Установил права на выполнение скрипта
8 [root@pam ~] ll /usr/local/bin/login.sh
# Проверил права на запуск скрипта
9 [root@pam ~] vi /etc/pam.d/sshd
# Редактирую sshd конфиг для загрузки скрипта
10 [root@pam ~] systemctl restart sshd.service 
# Рестартую сервис sshd для применения настроек
11 [root@pam ~] sudo date 020922302024.00
# Устанавливаю будний день. Проверяю, что пользователи otus, otusadm могут подключаться по команде ssh otus|otusadm@192.168.57.10
12 [root@pam ~] sudo date 021013122024.00
# Устанавливаю выходной день. Убеждаюсь, пользователь otus не может подключиться через ssh 
