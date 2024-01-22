ЗАДАНИЕ 1. DOCKER
1. Установите Docker на хост машину
https://docs.docker.com/engine/install/ubuntu/

2. Установите Docker Compose - как плагин, или как отдельное приложение
Решение:
104  sudo apt-get update
105  sudo apt-get install ca-certificates curl gnupg
106  sudo install -m 0755 -d /etc/apt/keyrings
107  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
108  sudo chmod a+r /etc/apt/keyrings/docker.gpg
110  echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
111    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
112  sudo apt-get update
113  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
114  sudo docker run hello-world

3. Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
см. Dockerfile

4. Определите разницу между контейнером и образом
Контейнер содержит готовое окружение для запуска приложений. Образ содержит файлы, настройки для поднятия контейнера, т.е. образ является шаблоном для контейнера
Вывод опишите в домашнем задании.

5. Ответьте на вопрос: Можно ли в контейнере собрать ядро?
Контейнеры используют ядро хостовой машины, поэтому собрать в контейнере ядро отличное от хостового не получиться. В этом случае нужно использовать виртуальные машины.
