Занятие 1. Vagrant-стенд для обновления ядра и создания образа системы

Описание домашнего задания
1) Запустить ВМ с помощью Vagrant.
2) Обновить ядро ОС из репозитория ELRepo.
3) Оформить отчет в README-файле в GitHub-репозитории.

Команды:
#1. Скачать образ VagrantBox
curl -L -O 'https://app.vagrantup.com/generic/boxes/centos8s/versions/4.3.12/providers/virtualbox/amd64/vagrant.box' 
#2. Экспортировать образ в систему
vagrant box add --name 'generic/centos8s' vagrant.box
#3. Проверяем, что образ появился в системе
vagrant box list
#4. Создаем Vagrantfile для развертывания образа
nano Vagrantfile
#5. Проверяем Vagrantfile на корректность настроек
vagrant validate
#6. Запускаем создание виртуальной машины 
vagrant up
#7. Подключаемся к созданной виртуальной машине
vagrant ssh
#8. Проверяем текущую версию ядра linux
uname -r
#9. Устанавливаем репозиторий с новыми версиями ядра
sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
#10. Пересобираем grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
#11. Прописываем в загрузчике загрузку с новой версией ядра
sudo grub2-set-default 0
#12. Перезагружаю виртуальную машину
sudo reboot
#13. Проверяю новую версию ядра
uname -r
