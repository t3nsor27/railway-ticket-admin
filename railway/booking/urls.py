from django.urls import path
from . import views

app_name = "booking"
urlpatterns = [
    path('test', views.test_view, name="test"),
    path('form-test/', views.form_test, name="form-test"),
    path('', views.login_view, name="login"),
    path('home/', views.home_view, name="home"),
    path('train/', views.train_view, name="train"),
    path('pay/', views.pay_view, name="pay"),
    path('update-price/', views.update_price, name="update-price"),
    path('confirm/', views.confirm_view, name="confirm"),
    path('cancel/', views.cancel_view, name="cancel")
]
