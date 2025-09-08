# Use official Python base image
FROM FROM public.ecr.aws/docker/library/python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
RUN apt-get update && apt-get dist-upgrade -y && rm -rf /var/lib/apt/lists/*
RUN apt-get update && \
    apt-get install -y --only-upgrade \
        libc-bin \
        coreutils \
        bash \
        dpkg \
        apt \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    urllib3

# Copy application code
COPY . .

# Command to run the app
CMD ["python", "app.py"]
