from django.http import HttpResponse
from django.shortcuts import render
import pathlib

from visits.models import Visit

this_dir = pathlib.Path(__file__).resolve().parent


def home_view(request, *args, **kwargs):
    return about_view(request, *args, **kwargs)

def about_view(request, *args, **kwargs):
    page_qs = Visit.objects.filter(path=request.path)
    qs = Visit.objects.all()

    try:
        percent = (page_qs.count() * 100) / qs.count()
    except:
        percent = 0

    title = "home page"
    context = {
        'title': title,
        'page_visit_count': page_qs.count(),
        'percent': percent,
        'total_visit_count': qs.count(),
    }
    path = request.path 
    print('path', path)
    html_template = 'home.html'
    Visit.objects.create(path=request.path)
    return render(request, html_template, context)

def old_home_page_view(request, *args, **kwargs):
    print(this_dir)
    html = ''
    html_file_path = this_dir / "home.html"
    html = html_file_path.read_text()

    return HttpResponse(html)