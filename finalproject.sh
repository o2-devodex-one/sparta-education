#!/bin/bash

# Bash script for install the nasa flask app on Ubuntu 24

# update packages
sudo apt update -y

# upgrade packages
sudo apt upgrade -y

# install necessery packages
sudo apt install git software-properties-common nginx sed python3-pip python3-venv -y

# get the app code
sudo git clone https://github.com/davidrichardharvey/nasa-flask-app

# Change nginx config
sudo sed -i '51c\proxy_pass http://127.0.0.1:5000;' /etc/nginx/sites-available/default

# Set the environment variable `NASA_API_KEY` before running the app
export NASA_API_KEY=cx9aqJ0ghHHsTpbPhokA9itBrG2AklAJcgnXgMiN

# Create app and setup app directory
cd nasa-flask-app
sudo chown -R $USER:$USER /home/ubuntu/nasa-flask-app

# PIP requirements
cat <<EOF > requirements.txt
Flask
requests
gunicorn
EOF


# Create virtual environment and install Python dependencies
python3 -m venv venv
./venv/bin/pip install -r requirements.txt

# Setup the Gunicorn process manager
sudo tee /etc/systemd/system/nasaflaskapp.service > /dev/null << 'EOF'
[Unit]
Description=Gunicorn instance for nasa-flask-app
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/nasa-flask-app
Environment="NASA_API_KEY=cx9aqJ0ghHHsTpbPhokA9itBrG2AklAJcgnXgMiN"
ExecStart=/home/ubuntu/nasa-flask-app/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

# restart & enbale nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# Use the process manager to keep Gunicorn running in the background and on startup
sudo systemctl daemon-reload
sudo systemctl enable nasaflaskapp
sudo systemctl start nasaflaskapp
sudo systemctl status nasaflaskapp