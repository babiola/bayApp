from django.shortcuts import render
from django.http import HttpResponseRedirect
from django.views.generic import TemplateView
from django.views.generic import ListView,DetailView
from django.views.generic.edit import FormView
from artist.models import Artist
from artist.form import artistForm
# Create your views here.
class artistview(TemplateView):
    template_name = "index.html"
class artistlist(ListView):
    model = Artist
    template_name = "list.html"
class artistadd(FormView):
    template_name = "add.html"
    form_class = artistForm
    success_url = '/thanks/'
    def form_valid(self, form):
        firstname = form.cleaned_data['firstname']
        lastname = form.cleaned_data['lastname']
        email = form.cleaned_data['email']
        p = Artist(firstname=firstname, lastname=lastname, email=email)
        p.save()
        return super().form_valid(form)
class artistthanks(TemplateView):
    template_name = "thanks.html"
class artistdetails(DetailView):
    model = Artist
    template_name = "details.html"