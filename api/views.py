from rest_framework import generics, status
from rest_framework.response import Response
import logging
from django.contrib.auth.hashers import check_password
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.core.mail import send_mail
from django.conf import settings
from django.utils.encoding import force_bytes, force_str
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.shortcuts import render
from .models import Event, Currency, User

from .serializers import EventSerializer, CurrencySerializer, UserSerializer
from twilio.rest import Client
from rest_framework_simplejwt.tokens import RefreshToken
import random
from django.contrib import messages
from django.shortcuts import render, redirect, get_object_or_404
logger = logging.getLogger(__name__)
# Create your views here.

class EventList(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Event.objects.all()
    serializer_class = EventSerializer

    def get(self, request, *args, **kwargs):
        logger.debug("Received GET request")
        return super().get(request, *args, **kwargs)
    
    def put(self, request, *args, **kwargs):
        event_id = kwargs.get('pk')
        try:
            event = Event.objects.get(pk=event_id)
            event.type = request.data.get('type')
            event.currency = request.data.get('currency')
            event.amount = request.data.get('amount')
            event.rate = request.data.get('rate')
            event.total = request.data.get('total')
            event.save()
            return Response(status=status.HTTP_200_OK)
        except Event.DoesNotExist:
            logger.error(f"Event with ID {event_id} not found")
            return Response(
                {"error": "Event not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error updating event: {str(e)}")
            return Response(
                {"error": "Failed to update event"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def post(self, request, *args, **kwargs):
        logger.debug(f"Received POST data: {request.data}")
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        logger.error(f"Validation errors: {serializer.errors}")
        return Response(
            {
                "error": "Invalid data",
                "details": serializer.errors
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    def delete(self, request, *args, **kwargs):
        event_id = kwargs.get('pk')
        logger.debug(f"Attempting to delete event with ID: {event_id}")

        try:
            event = Event.objects.get(pk=event_id)
            event.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Event.DoesNotExist:
            logger.error(f"Event with ID {event_id} not found")
            return Response(
                {"error": "Event not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error deleting event: {str(e)}")
            return Response(
                {"error": "Failed to delete event"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class CurrencyList(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        if self.request.method == 'GET':
            return Currency.objects.values('name')
        return Currency.objects.all()
    serializer_class = CurrencySerializer

    def delete(self, request, *args, **kwargs):
        currency_name = request.data.get('name')
        try:
            currency = Currency.objects.get(name=currency_name)
            currency.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Currency.DoesNotExist:
            logger.error(f"Currency with name {currency_name} not found")
            return Response(
            {"error": "Currency not found"},
            status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error deleting currency: {str(e)}")
            return Response(
            {"error": "Failed to delete currency"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def put(self, request, *args, **kwargs):
        currency_name = request.data.get('newName')
        currency_old_name = request.data.get('oldName')
        try:
            currency = Currency.objects.get(name=currency_old_name)
            currency.name = currency_name
            currency.save()
            return Response(status=status.HTTP_200_OK)
        except Currency.DoesNotExist:
            logger.error(f"Currency with name {currency_old_name} not found")
            return Response(
                {"error": "Currency not found"}, status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error updating currency: {str(e)}")
            return Response(
                {"error": "Failed to update currency"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

class UsersList(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get(self, request, *args, **kwargs):
        if not kwargs.get('username'):
            return super().get(request, *args, **kwargs)
        user_id = kwargs.get('username')
        return Response(
            UserSerializer(User.objects.get(username=user_id)).data,
            status=status.HTTP_200_OK
        )

    def post(self, request, *args, **kwargs):
        logger.debug(f"Received POST data: {request.data}")
        username = request.data.get('username')
        password = request.data.get('password')
        
        # Check if user already exists
        if User.objects.filter(username=username).exists():
            return Response(
                {
                    "error": "Имя пользователя уже занято",
                    "details": "A user with this username already exists"
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        elif User.objects.filter(email=request.data.get('email')).exists():
            return Response(
                {
                    "error": "Эта почта уже зарегистрирована",
                    "details": "A user with this email already exists"
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        elif User.objects.filter(phone=request.data.get('phone')).exists():
            return Response(
                {
                    "error": "Этот номер уже зарегистрирован",
                    "details": "A user with this phone number already exists"
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
            
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            # Get validated data
            validated_data = serializer.validated_data
            # Remove password from validated data
            password = validated_data.pop('password', None)
            # Create user instance
            user = User(**validated_data)
            # Set password properly to ensure it's hashed
            user.set_password(password)
            user.save()
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
            
        logger.error(f"Validation errors: {serializer.errors}")
        return Response(
            {
                "error": "Invalid data",
                "details": serializer.errors
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    def put(self, request, *args, **kwargs):
        new_user_id = request.data.get('username')
        old_user_id = request.data.get('oldUsername')
        is_superuser = request.data.get('isSuperUser')
        email = request.data.get('email')
        logger.debug(is_superuser)
        print(is_superuser)
        if request.data.get('password'):
            new_password = request.data.get('password')
        else:
            new_password = None
        try:
            user = User.objects.get(username=old_user_id)
            if new_password:
                user.set_password(new_password)
            user.username = new_user_id
            user.is_superuser = True if is_superuser else False
            user.email = email
            user.save()
            return Response(status=status.HTTP_200_OK)
        except User.DoesNotExist:
            logger.error(f"User with ID {old_user_id} not found")
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error updating user: {str(e)}")
            return Response(
                {"error": "Failed to update user"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def delete(self, request, *args, **kwargs):
        user_id = request.data.get('username')
        logger.debug(f"Attempting to delete user with ID: {user_id}")
        try:
            user = User.objects.get(username=user_id)
            user.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except User.DoesNotExist:
            logger.error(f"User with ID {user_id} not found")
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error deleting user: {str(e)}")
            return Response(
                {"error": "Failed to delete user"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ClearAll(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        username = request.data.get('username')
        password = request.data.get('password')
        superAdminsList = User.objects.filter(is_superuser=True)
        for superAdmin in superAdminsList:
            if superAdmin.username == username and check_password(password, superAdmin.password):
                Event.objects.all().delete()
                return Response({"message": "Clear successful"}, status=status.HTTP_200_OK)
        return Response({"error": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)


class isSuperAdmin(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        username = kwargs.get('username')
        try:
            superAdmin = User.objects.get(username=username)
        except User.DoesNotExist:
            return Response({"error": "Not superadmin"}, status=status.HTTP_400_BAD_REQUEST)
        if superAdmin.is_superuser:
            return Response(status=status.HTTP_204_NO_CONTENT)
        return Response({"error": "Not superadmin"}, status=status.HTTP_400_BAD_REQUEST)



class testRenderResetTemplateUi(APIView):
    permission_classes = [AllowAny]

    def get(self, request, *args, **kwargs):
        return render(request, 'password_reset_confirm.html', {'validlink': True, 'uidb64': 'uidb64', 'token': 'token'})
from rest_framework.response import Response
from django.contrib.auth.models import User
from rest_framework import status
import logging
logger = logging.getLogger(__name__)


