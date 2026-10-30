from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path, re_path
from django.views.static import serve

urlpatterns = [
    path("admin/", admin.site.urls),

    # Direct root static asset resolvers for relative HTML paths
    re_path(r"^styles\.css$", serve, {"document_root": settings.STATICFILES_DIRS[0], "path": "styles.css"}),
    re_path(r"^script\.js$", serve, {"document_root": settings.STATICFILES_DIRS[0], "path": "script.js"}),
    re_path(r"^api-client\.js$", serve, {"document_root": settings.STATICFILES_DIRS[0], "path": "api-client.js"}),
    re_path(r"^favicon\.svg$", serve, {"document_root": settings.STATICFILES_DIRS[0], "path": "favicon.svg"}),
    re_path(r"^assets/(?P<path>.*)$", serve, {"document_root": settings.STATICFILES_DIRS[0] / "assets"}),

    # Hospital URLs (Frontend HTML Pages & REST APIs)
    path("", include("hospital.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
