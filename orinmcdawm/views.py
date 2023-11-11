from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.contrib.gis.geos import Point
from .models import Profile
import json


def map_view(request):
    return render(request, 'map.html')


@login_required
def update_location(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            latitude = data.get('latitude')
            longitude = data.get('longitude')

            profile, created = Profile.objects.get_or_create(user=request.user)

            # Update the user's profile with the new location
            profile.lat = latitude
            profile.lon = longitude
            profile.save()

            return JsonResponse({'status': 'success'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'})
