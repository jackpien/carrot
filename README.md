# Setup celery with SQS and EBS

Inspired by https://howto.lintel.in/configure-celery-sqs-django-elastic-beanstalk/ and https://realpython.com/asynchronous-tasks-with-django-and-celery/ and http://diegojancic.blogspot.com/2016/12/making-celery-4-work-in-django-110-and.html

1. pip install celery[sqs]
1. aws sqs create-queue --queue-name dev-celery

##  Start worker

1. celery worker --app=carrot --loglevel=INFO

## Start a beat

1. celert beat --app=carrot --loglevel=INFO

## Push a message

1. python manage.py shell
   1. from carrot import celery
   1. celery.debug_task.delay()

## Create new tasks

In each app folder, create a file tasks.py

## Worker and Beat Daemon on EBS


https://stackoverflow.com/questions/29205720/daemonize-celerybeat-in-elastic-beanstalkaws

1. sudo yum install -y openssl-devel.x86_64 libcurl-devel.x86_64
1. sudo apt-get install libcurl4-openssl-dev libssl-dev