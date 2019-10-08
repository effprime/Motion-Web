import requests
import logging
import datetime
import json
import time
import os

LOOP_TIME = 30
INITIAL_WAIT_TIME = 5
JSON_FILE = "status.json"

class StatusKeeper():


    def __init__(self, cameras, api_url):
        """
        Initializes the StatusKeeper daemon.

        cameras (int): The number of active cameras in Motion.
        api_url (str): The URL for accessing the Motion API.
        """

        logging.getLogger().setLevel(logging.INFO)
        logging.info("Starting status keeping with %s cameras" % cameras)
        self.cameras = [str(i) for i in range(1,int(cameras)+1)]
        self.APIURL = "http://%s" % (api_url)
        self.run()


    # private methods
    def __get_API_command(self, info):
        """
        Maps an API response chunk to the send chunk.

        info (str): API response chunk.
        """

        info = info.lower() if info else None
        if info == "active":
            return "start"
        elif info == "pause":
            return "pause"
        return None


    def __initialize_status(self):
        """
        Creates the status attribute with null entries.
        """

        self.status = {}
        for cam in self.cameras:
            self.status[cam] = None
        self.__set_status_timestamp()


    def __set_status_timestamp(self):
        """
        Adds a timestamp entry to the status attribute.
        """

        self.status["time"] = str(datetime.datetime.now())


    def __wait(self, time_):
        """
        Wraps the sleep function with logging.

        time (int): The amount of seconds to wait.
        """

        logging.info("Sleeping for %s seconds" % (time_))
        time.sleep(time_)


    # public methods
    def get_status_from_API(self):
        """
        Updates status attribute from API responses.
        """

        logging.info("Getting status from Motion API")
        for cam in self.cameras:
            status = requests.get("%s/%s/detection/status" % (self.APIURL, cam)).text.split()[-1]
            if status == "valid":
                status = None
            logging.info("API Camera %s status: %s" % (cam, status))
            self.status[cam] = status
        self.__set_status_timestamp()


    def get_status_from_JSON(self):
        """
        Updates status attribute from local JSON file.
        """

        logging.info("Getting current status from JSON")
        if os.path.exists(JSON_FILE):
            with open('status.json', 'r') as file:
                self.status = json.load(file)
            for cam, status in list(self.status.items())[:-1]:
                logging.info("JSON Camera %s status: %s" % (cam, status))
        else:
            logging.info("JSON file not found -- new file will be created")


    def log_status_to_JSON(self):
        """
        Saves the status attribute to local JSON file.
        """

        logging.info("Saving current status to JSON")
        with open(JSON_FILE, 'w') as file:
            json.dump(self.status, file)


    def send_status_to_API(self):
        """
        Sends commands to API based on status attribute.
        """

        logging.info("Sending current status to API")
        for cam in self.cameras:
            command = self.__get_API_command(self.status[cam])
            if command:
                requests.get("%s/%s/detection/%s" % (self.APIURL, cam, command))
            else: 
                logging.error("Invalid status for Camera %s" % (cam))


    def run(self):
        """
        Runs startup functions and loops through get/save functions.
        """

        self.__initialize_status()
        self.get_status_from_JSON()
        self.send_status_to_API()
        self.__wait(INITIAL_WAIT_TIME)
        while True:
            self.get_status_from_API()
            self.log_status_to_JSON()
            self.__wait(LOOP_TIME)
