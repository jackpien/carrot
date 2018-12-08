# Copyright (c) 2018 AF386 Group LLC

from django.urls import path, re_path
from django.views.generic import TemplateView, RedirectView


app_name = "stick"

urlpatterns = [
    path('',
         TemplateView.as_view(
            template_name='stick/home.html'),
         name='home'),
    ]
