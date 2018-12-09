from django.contrib.auth.models import User
from celery.decorators import task, periodic_task
from celery.task.schedules import crontab
from datetime import timedelta

@task(bind=True)
def debug_task_stick(self, prefix=""):
    all_users = User.objects.all()
    print(f"{prefix}Number of users: {len(all_users)}")
    for uuu in all_users:
        print(f"User: {uuu.email}")
    #print('Request: {0!r}'.format(self.request))

@periodic_task(
    #run_every=(crontab(minute='*/1')),
    run_every=timedelta(seconds=30),
    name="fetch_users",
    ignore_result=True
)
def task_fetch_users():
    """
    Saves latest image from Flickr
    """
    debug_task_stick()
