from django.contrib.auth.models import User
from celery.decorators import task, periodic_task
from celery.task.schedules import crontab
from datetime import timedelta

@task(bind=True)
def debug_task_stick(self, prefix=""):
    try:
        all_users = User.objects.all()
        print(f"{prefix}Number of users: {len(all_users)}")
        for uuu in all_users:
            print(f"User: {uuu.email}")
    except:
        print(f"No access to DB")
    print('Request: {0!r}'.format(self.request))

@task(bind=True)
def add(self, x, y):
    return x + y

@task(bind=True)
def mult(self, x, y):
    return x * y

@task(bind=True)
def get_num_users(self, x):
    all_users = User.objects.all()
    return {
        "num_users": len(all_users)
    }
        

#@periodic_task(
#    #run_every=(crontab(minute='*/1')),
#    run_every=timedelta(seconds=30),
#    name="fetch_users",
#    ignore_result=True
#)
#def task_fetch_users():
#    """
#    Saves latest image from Flickr
#    """
#    debug_task_stick()
