Домашнее задание
Практика с SELinux
Задание: 
    1. Запустить nginx на нестандартном порту 3-мя разными способами: 
    • переключатели setsebool; 
    • добавление нестандартного порта в имеющийся тип; 
    • формирование и установка модуля SELinux.
К сдаче: 
    • README с описанием каждого решения (скриншоты и демонстрация приветствуются).
Команды:
# Разворачиваем виртуальную машину из файла Vagrantfile
albert@albert-H110:~/otus/l12_selinux$ vagrant up
# Подключаемся к виртуальной машине
albert@albert-H110:~/otus/l12_selinux$ vagrant ssh
# Повышаем привелегии до root
[vagrant@localhost ~]$ sudo -i
# Установил epel-release, т.к. через скрипт Vagrantfile он не установился
[root@localhost ~]# yum install -y epel-release
# Установил nginx по той же причине
[root@localhost ~]# yum install -y nginx
# Переопределил порт nginx в конфигурации
[root@localhost ~]# sed -ie 's/:80/:4881/g' /etc/nginx/nginx.conf
# Переопределил прослушивание на порту 4881 в конфигурации nginx
sed -i 's/listen       80;/listen       4881;/' /etc/nginx/nginx.conf
# При запуске nginx выадает ошибку
[root@localhost ~]# systemctl start nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

# Проверил, что firewall не запущен
[root@localhost ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

# Проверил режим работы selinux
[root@localhost ~]# getenforce
Enforcing

# Убедился, что nginx не запущен из-за переопределенного порта 
[root@localhost ~]# systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Tue 2024-01-16 11:39:12 UTC; 16s ago
  Process: 2469 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 2468 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)

Jan 16 11:39:12 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 11:39:12 localhost.localdomain nginx[2469]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 11:39:12 localhost.localdomain nginx[2469]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
Jan 16 11:39:12 localhost.localdomain nginx[2469]: nginx: configuration file /etc/nginx/nginx.conf test failed
Jan 16 11:39:12 localhost.localdomain systemd[1]: nginx.service: control process exited, code=exited status=1
Jan 16 11:39:12 localhost.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Jan 16 11:39:12 localhost.localdomain systemd[1]: Unit nginx.service entered failed state.
Jan 16 11:39:12 localhost.localdomain systemd[1]: nginx.service failed.

# Проверил правильность конфигурации nginx
[root@localhost ~]# getenforce
Enforcing

# Установил утилиты для работы с selinux
[root@localhost ~]# yum install -y setroubleshoot-server selinux-policy-mls setools-console policycoreutils-python policycoreutils-newrole

# С помощью утилиты audit2why сгенерировал команду для исправления ошибки запуска nginx
[root@localhost ~]# grep 1705405152.725:641 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1705405152.725:641): avc:  denied  { name_bind } for  pid=2469 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

	Was caused by:
	The boolean nis_enabled was set incorrectly. 
	Description:
	Allow nis to enabled

	Allow access by executing:
	# setsebool -P nis_enabled 1

# Включил параметр nis_enabled 
setsebool -P nis_enabled 1
# Перезапустил nginx, убедился, что он запустился
[root@localhost ~]# systemctl restart nginx
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2024-01-16 11:58:03 UTC; 17s ago

# Удостоверился, что параметр nis_enabled включен
[root@localhost ~]# getsebool -a | grep nis_enabled
nis_enabled --> on

# Отключил параметр
[root@localhost ~]# setsebool -P nis_enabled off

# Перезапустил nginx
[root@localhost ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

# Убедился, что nginx не запустился
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Wed 2024-01-17 03:10:17 UTC; 8s ago

# Проверил порты включенные на протоколе http
[root@localhost ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989

# Добавил порт 4881 в протокол http
[root@localhost ~]# semanage port -a -t http_port_t -p tcp 4881

# Подтвердил, что на порт включен в http
[root@localhost ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989

# Перезапустил nginx, убедился, что он запускается без ошибок
[root@localhost ~]# systemctl restart nginx
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2024-01-17 03:12:22 UTC; 12s ago

# Удалил порт 4881 из разрешенных в http
[root@localhost ~]# semanage port -d -t http_port_t -p tcp 4881
[root@localhost ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000

# Перезапустил nginx, убедился, что он не запускается из-за ошибки
[root@localhost ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Wed 2024-01-17 03:15:50 UTC; 39s ago

# С помощью утилиты audit2allow сформировал файл с правилами, разрешающими проблемы с запуском nginx и преминил их
[root@localhost ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

[root@localhost ~]# semodule -i nginx.pp

# Убедился, что nginx после применения правил запускается нормально
[root@localhost ~]# systemctl start nginx
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2024-01-17 03:36:19 UTC; 4s ago

# Проверил установку модуля nginx
[root@localhost ~]# semodule -l


# Удалил модуль nginx
[root@localhost ~]# semodule -r nginx
libsemanage.semanage_direct_remove_key: Removing last nginx module (no other nginx module exists at another priority).

# Проверил, что после удаления модуля, nginx не запускается
[root@localhost ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Wed 2024-01-17 05:16:35 UTC; 10min ago
  Process: 22665 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22752 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
