# Motion-Web
Provides a web interface for accessing and controlling cameras using the Linux software `Motion`

**Setup**
* Run the `start.sh` script to create an .env file and bring up the project
* The script will also run `--build` to create images based on the .env file

**Notes**
* Docker and Docker-Compose are required
* Currently this only works for IP cameras
* A status-keeping container runs alongside Motion and Nginx to persist detection settings
