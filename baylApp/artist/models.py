from django.db import models
from django import forms
# Create your models here.
class Artist(models.Model):
    firstname = models.CharField(max_length=30)
    lastname = models.CharField(max_length=50)
    email = models.EmailField(max_length=60)
    def __str__(self):
        return self.firstname