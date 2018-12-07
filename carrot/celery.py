from __future__ import absolute_import, unicode_literals
import os
from celery import Celery
# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'carrot.settings')

app = Celery('carrot')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django app configs.
app.autodiscover_tasks()

@app.task(bind=True)
def debug_task(self):
    from django.contrib.auth.models import User
    all_users = User.objects.all()
    print(f"Number of users: {len(all_users)}")
    for uuu in all_users:
        print(f"User: {uuu.email}")
    #print('Request: {0!r}'.format(self.request))
