# gvm21.4-docker
This is the docker sample of the GVM 21.4 

This image based on the Ubuntu Focal (20.04). This repo aims to install GVM 21.4 with only a dockerfile instead of docker-compose.

**Build**

    docker build -t gvm:1.0 .
    
**Launch**

    docker run -it --name gvm-container -p 8080:9392 gvm:1.0
    
**Accessing Web UI**

    http://127.0.0.1:8080
    admin:admin
