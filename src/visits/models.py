from django.db import models

# Create your models here.
class Visit(models.Model):
    #db -> table
    #id -> hidden primary key -> autofield
    path = models.TextField(null=True, blank=True) # col
    timestamp = models.DateTimeField(auto_now_add=True) # col