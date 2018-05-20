"""baylApp URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from artist.views import artistview,artistlist,artistadd,artistthanks,artistdetails

urlpatterns = [
    path('',artistview.as_view(template_name="index.html")),
    path('list/',artistlist.as_view(template_name="list.html")),
    path('list/add',artistadd.as_view(template_name="add.html")),
    path('thanks/',artistthanks.as_view(template_name="thanks.html")),
    path('list/details/<pk>/',artistdetails.as_view(template_name="details.html")),
    path('admin/', admin.site.urls),
    ]
