#!/usr/bin/env bash

# Create group called 'celery'
sudo groupadd -f celery
# add the user 'celery' if it doesn't exist and add it to the group with same name
id -u celery &>/dev/null || sudo useradd -g celery celery
# add permissions to the celery user for r+w to the folders just created
sudo chown -R celery:celery /var/log/celery/
sudo chown -R celery:celery /var/run/celery/

# Get django environment variables
celeryenv=`cat /opt/python/current/env | tr '\n' ',' | sed 's/export //g' | sed 's/$PATH/%(ENV_PATH)s/g' | sed 's/$PYTHONPATH//g' | sed 's/$LD_LIBRARY_PATH//g'`
celeryenv=${celeryenv%?}

celeryproject=carrot

# Create celery configuraiton script
celeryconf="[program:celeryd-worker]
; Set full path to celery program if using virtualenv
command=/opt/python/run/venv/bin/celery worker -A $celeryproject -P solo --loglevel=INFO -n worker.%%h --logfile='/var/log/celery/%%n%%I-worker.log' --pidfile='/var/run/celery/%%n.pid'

directory=/opt/python/current/app
user=celery
numprocs=1
stdout_logfile=/var/log/celery/worker.log
stderr_logfile=/var/log/celery/worker.log
autostart=true
autorestart=true
startsecs=10

; Need to wait for currently executing tasks to finish at shutdown.
; Increase this if you have very long running tasks.
stopwaitsecs = 600

; When resorting to send SIGKILL to the program to terminate it
; send SIGKILL to its whole process group instead,
; taking care of its children as well.
killasgroup=true

; if rabbitmq is supervised, set its priority higher
; so it starts first
priority=998

environment=$celeryenv
"


celerybeatconf="[program:celeryd-beat]
; Set full path to celery program if using virtualenv
command=/opt/python/run/venv/bin/celery beat -A $celeryproject --loglevel=INFO --logfile='/var/log/celery/celery-beat.log' --pidfile='/var/run/celery/celery-beat.pid' --schedule='/var/run/celery/beat.db' 

directory=/opt/python/current/app
user=celery
numprocs=1
stdout_logfile=/var/log/celery/beat.log
stderr_logfile=/var/log/celery/beat.log
autostart=true
autorestart=true
startsecs=10

; Need to wait for currently executing tasks to finish at shutdown.
; Increase this if you have very long running tasks.
stopwaitsecs = 600

; When resorting to send SIGKILL to the program to terminate it
; send SIGKILL to its whole process group instead,
; taking care of its children as well.
killasgroup=true

; if rabbitmq is supervised, set its priority higher
; so it starts first
priority=998

environment=$celeryenv
"

# Create the celery supervisord conf script
echo "$celeryconf" | tee /opt/python/etc/celery.conf
echo "$celerybeatconf" | tee /opt/python/etc/celery-beat.conf

# Add configuration script to supervisord conf (if not there already)
if ! grep -Fxq "[include]" /opt/python/etc/supervisord.conf
  then
  echo "[include]" | tee -a /opt/python/etc/supervisord.conf
  echo "files: celery-beat.conf celery.conf" | tee -a /opt/python/etc/supervisord.conf
fi

# Reread the supervisord config
/usr/local/bin/supervisorctl -c /opt/python/etc/supervisord.conf reread

# Update supervisord in cache without restarting all services
/usr/local/bin/supervisorctl -c /opt/python/etc/supervisord.conf update celeryd-worker

# Start/Restart celeryd through supervisord
/usr/local/bin/supervisorctl -c /opt/python/etc/supervisord.conf restart celeryd-worker

# Start with leader only in config
# /usr/local/bin/supervisorctl -c /opt/python/etc/supervisord.conf restart celeryd-beat
