# Use a smaller base image
FROM continuumio/miniconda3

# Set maintainer label
LABEL maintainer="OrinMcD"

# Set environment variables
ENV PYTHONUNBUFFERED 1
ENV DJANGO_SETTINGS_MODULE=geodjango.settings

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-cffi \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    binutils \
    libproj-dev \
    gdal-bin \
    libgdal-dev \
    shared-mime-info \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy Conda environment file and create it
COPY ENV.yml /usr/src/app
RUN conda env create -n geodjango --file ENV.yml

# Activate Conda environment
RUN echo "conda activate geodjango" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Set up Conda channels and install uWSGI
RUN conda config --add channels conda-forge && conda config --set channel_priority strict
RUN conda install uwsgi

# Copy your Django project into the image
COPY . /usr/src/app

# Make sure that static files are up to date and available
#RUN python manage.py collectstatic --no-input

# Collect static files (inside the activated environment)
CMD /bin/bash -c "python manage.py collectstatic --no-input"

# Copy the uwsgi.ini file
COPY uwsgi.ini ./bin/sh/


# Expose the port
EXPOSE 8001
EXPOSE 8000

# Define the entrypoint
#ENTRYPOINT ["uwsgi", "--ini", "uwsgi.ini"]
CMD uwsgi --ini uwsgi.ini