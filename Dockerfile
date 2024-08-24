# Use a Windows base image with Python pre-installed
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set the Python version as a build-time argument with Python 3.12 as the default
ARG PYTHON_VERSION=3.12

# Install Python
RUN powershell -Command `
RUN Invoke-WebRequest -Uri https://www.python.org/ftp/python/${env:PYTHON_VERSION}/python-${env:PYTHON_VERSION}-embed-win32.zip -OutFile python.zip; `
RUN Expand-Archive python.zip -DestinationPath C:\Python; `
RUN Remove-Item python.zip; `
RUN [Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Python', [System.EnvironmentVariableTarget]::Machine)

# Create a virtual environment
RUN C:\Python\python.exe -m venv C:\opt\venv

# Set the virtual environment as the current location
ENV PATH=C:/opt/venv/Scripts:$PATH

# Upgrade pip
RUN pip install --upgrade pip

# Set Python-related environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install Windows dependencies (e.g., using Chocolatey)
# Make sure to install Chocolatey first if not already installed
RUN powershell -Command `
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; `
RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
RUN choco install -y libpq libjpeg cairo gcc

# Create the mini vm's code directory
RUN mkdir C:\code

# Set the working directory to that same code directory
WORKDIR C:/code

# Copy the requirements file into the container
COPY requirements.txt C:/tmp/requirements.txt

# Copy the project code into the container's working directory
COPY ./src C:/code

# Install the Python project requirements
RUN pip install -r C:/tmp/requirements.txt

# Set the Django default project name
ARG PROJ_NAME="cfehome"

# Create a PowerShell script to run the Django project
# This script will execute at runtime when the container starts
RUN echo '@echo off' > C:/paracord_runner.bat && `
RUN echo set RUN_PORT=%PORT% >> C:/paracord_runner.bat && `
RUN echo python manage.py migrate --no-input >> C:/paracord_runner.bat && `
RUN echo gunicorn %PROJ_NAME%.wsgi:application --bind "0.0.0.0:%RUN_PORT%" >> C:/paracord_runner.bat

# Run the Django project via the runtime script when the container starts
CMD ["C:\\paracord_runner.bat"]
