# Base image
FROM ubuntu:22.04

# Set environment variables to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install necessary dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    git \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libsasl2-dev \
    libldap2-dev \
    libjpeg8-dev \
    libblas-dev \
    libatlas-base-dev \
    libssl-dev \
    libffi-dev \
    python3-pip \
    nodejs \
    npm \
    postgresql-client \
    fonts-dejavu-core \
    fonts-freefont-ttf \
    fonts-freefont-otf \
    fonts-noto-core \
    fonts-inconsolata \
    fonts-font-awesome \
    fonts-roboto-unhinted \
    gsfonts \
    p7zip-full

# Copy your local Odoo code into the Docker image
COPY . /opt/odoo

# Install Python virtual environment
RUN python3 -m pip install virtualenv && virtualenv -p python3.10 /opt/odoo/venv

# Install Python dependencies from requirements.txt
RUN /opt/odoo/venv/bin/pip install -r /opt/odoo/requirements.txt

# Install Node.js and rtlcss for right-to-left language support
RUN npm install -g rtlcss

RUN apt-get install -y curl
RUN apt-get install python3-pypdf2

# Install wkhtmltopdf manually (version 0.12.6 for Odoo reports)
RUN curl -o wkhtmltox.deb -sSL https://nightly.odoo.com/deb/jammy/wkhtmltox_0.12.5-2.jammy_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Create an Odoo user
RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

# Set permissions
RUN chown -R odoo:odoo /opt/odoo

# Expose the necessary port
EXPOSE 8069

# Switch to odoo user
USER odoo

# Set the working directory
WORKDIR /opt/odoo

# Start Odoo with environment variables for PostgreSQL credentials
CMD ["/opt/odoo/venv/bin/python", "/opt/odoo/odoo-bin", "--addons-path=/opt/odoo/addons", "-d", "odoo", "--db_host=dpg-csblpqlds78s73ba4520-a", "--db_user=odoo", "--db_password=sNw9kAStYUtkloLU3RhcSbQ9B2HeN9Jc", "--db_port=5432", "--db-filter=^odoo$", "-i", "base", "--db_name=odoo_pm4h"]
