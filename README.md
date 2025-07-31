# Web Infrastructure Lab

This project lets you run a simple web infrastructure on your computer using Docker. It includes two web servers and a load balancer, so you can see how real websites handle traffic. **No technical background required!**

---

## What’s Included?

- **web-01** and **web-02**: Two web servers, both using the Docker image [`twariq/medprice:v1`](https://hub.docker.com/r/twariq/medprice).  
  > This image runs a medical information web app. You can read the full app documentation [here](https://github.com/TWARIQABDUL/medicalinformation/blob/master/README.md).
- **lb-01**: A load balancer that splits traffic between the web servers.
- **Docker Compose**: Makes it easy to start and stop everything with one command.

---

## Requirements

- **Docker** and **Docker Compose** installed on your computer.
  - [Get Docker](https://docs.docker.com/get-docker/)
  - [Get Docker Compose](https://docs.docker.com/compose/install/)
- At least **2 GB RAM** and some free disk space.

---

## How to Start

1. **Download the project**
   ```bash
   git clone <repo-url>
   cd web_infra_lab
   ```

2. **Start the lab**
   ```bash
   docker compose up -d --build
   ```
   This will automatically pull the `twariq/medprice:v1` image for the web servers.

3. **Check if it’s running**
   ```bash
   docker compose ps
   ```
   You should see `web-01`, `web-02`, and `lb-01` listed.

---

## Accessing the Servers

- **web-01:** [http://localhost:8080](http://localhost:8080)
- **web-02:** [http://localhost:8083](http://localhost:8083)
- **Load Balancer (lb-01):** [http://localhost:8082](http://localhost:8082)

---

## Using and Configuring the Load Balancer (`lb-01`)

### SSH Access

You can connect to the load balancer container using SSH:

```bash
ssh ubuntu@localhost -p 2210
# Password: pass123
```

- Username: `ubuntu`
- Password: `pass123`

### Initial Setup Script

When the `lb-01` container starts, 
runs a setup script: [`setup.sh`](lb/setup.sh).  
```bash
$ sudo /usr/local/bin/setup.sh
```
This script:
- Installs **HAProxy** (the load balancer software)
- Installs **nano** (a simple text editor)
- Prints instructions for further configuration

### Configuring HAProxy

1. **SSH into lb-01** (see above).
2. Open the HAProxy config file with nano:
   ```bash
   sudo nano /etc/haproxy/haproxy.cfg
   ```
3. **Make sure your configuration file contains the following sections:**

   **Global section:**
   ```
   global
       log /dev/log    local0
       log /dev/log    local1 notice
       chroot /var/lib/haproxy
       stats socket /run/haproxy/admin.sock mode 660 level admin
       stats timeout 30s
       user haproxy
       group haproxy
       daemon
       maxconn 256
   ```

   **Frontend and backend sections:**
   ```
   frontend http-in
       bind *:80
       default_backend servers

   backend servers
       balance roundrobin
       server web01 172.20.0.11:80 check
       server web02 172.20.0.12:80 check
       http-response set-header X-Served-By %[srv_name]
   ```

   These settings ensure the load balancer splits traffic between both web servers and adds a header to show which server handled the request.

4. Edit the configuration as needed (for example, to change backend servers or load balancing rules).
5. Restart HAProxy to apply changes:
   ```bash
   sudo systemctl restart haproxy
   ```

---

## See the Load Balancer in Action

You can test the load balancer by sending requests to its address and observing how it distributes traffic between the web servers. For example, run the following command multiple times:

```bash
curl -I http://localhost:8082
```

You should see responses alternating between `web01` and `web02` in the `x-served-by` header, like this:

```text
HTTP/1.1 200 OK
server: nginx/1.29.0
...
x-served-by: web01

HTTP/1.1 200 OK
server: nginx/1.29.0
...
x-served-by: web02
```

This shows that the load balancer is successfully distributing requests between your web servers.

---

## Stopping the Lab

To stop and remove everything, run:
```bash
docker compose down
```

---

## Troubleshooting

- If you get errors about ports in use, make sure nothing else is running on ports 8080, 8082, or 8083.
- To reset everything, run:
  ```bash
  docker compose down -v
  ```

---

## Summary

- **Start everything:** `docker compose up -d --build`
- **Visit your servers:** [http://localhost:8080](http://localhost:8080), [http://localhost:8083](http://localhost:8083), [http://localhost:8082](http://localhost:8082)
- **SSH to load balancer:** `ssh ubuntu@localhost -p 2210` (password: `pass123`)
- **Stop everything:** `docker compose down`

Enjoy experimenting with your own web infrastructure!