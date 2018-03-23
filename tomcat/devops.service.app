# DevOps Tomcat (Camunda, Alfresco) Systemd Startup script

[Unit]
Description=DevOps Tomcat Web-Server for Camunda-BPM and Alfresco-ECM
After=network.target

[Service]
Type=forking

ExecStart=/home/devops/tomcat/bin/startup.sh
ExecStop=/home/devops/tomcat/bin/shutdown.sh

User=devops
Group=devops
UMask=0007
RestartSec=15
Restart=always

WorkingDirectory=/home/devops/logs
LimitNOFILE=8192:65536

[Install]
WantedBy=multi-user.target