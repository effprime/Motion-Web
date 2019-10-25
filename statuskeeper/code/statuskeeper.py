"""Provides detection status keeping using a persistent JSON file.
"""
import datetime
import json
import logging
import os
import time

import requests

LOOP_TIME = 30
INITIAL_WAIT_TIME = 5
JSON_FILE = "status.json"


class StatusKeeper:
    """The object for performing detection status keeping.
    """

    def __init__(self, cameras, api_url, api_port):
        """Initializes the StatusKeeper daemon.

        args:
            cameras (int): The number of active cameras in Motion.
            api_url (str): The URL for accessing the Motion API.
            api_port (int): The port for accessing the Motion API.
        """
        logging.getLogger().setLevel(logging.INFO)
        logging.info("Starting status keeping with %s cameras", cameras)
        self.status = {}
        self.cameras = [str(i) for i in range(1, int(cameras) + 1)]
        self.api_url = "http://%s:%s" % (api_url, api_port)
        self.run()

    @staticmethod
    def get_api_command(info):
        """Maps an API response chunk to the send chunk.

        args:
            info (str): API response chunk.
        """
        info = info.lower() if info else None
        if info == "active":
            return "start"
        return info

    def get_status_from_api(self):
        """Updates status attribute from API responses.
        """
        logging.info("Getting status from Motion API")
        for cam in self.cameras:
            status = requests.get(
                "%s/%s/detection/status" % (self.api_url, cam)
            ).text.split()[-1]
            if status == "valid":
                status = None
            logging.info("API Camera %s status: %s", cam, status)
            self.status[cam] = status
        self.set_status_timestamp()

    def get_status_from_json(self):
        """Updates status attribute from local JSON file.
        """
        logging.info("Getting current status from JSON")
        if os.path.exists(JSON_FILE):
            with open("status.json", "r") as file:
                self.status = json.load(file)
            for cam, status in list(self.status.items())[:-1]:
                logging.info("JSON Camera %s status: %s", cam, status)
        else:
            logging.info("JSON file not found -- new file will be created")

    def initialize_status(self):
        """Creates the status attribute with null entries.
        """
        for cam in self.cameras:
            self.status[cam] = None
        self.set_status_timestamp()

    def log_status_to_json(self):
        """Saves the status attribute to local JSON file.
        """
        logging.info("Saving current status to JSON")
        with open(JSON_FILE, "w") as file:
            json.dump(self.status, file)

    def send_status_to_api(self):
        """Sends commands to API based on status attribute.
        """
        logging.info("Sending current status to API")
        for cam in self.cameras:
            command = StatusKeeper.get_api_command(self.status[cam])
            if command:
                requests.get("%s/%s/detection/%s" % (self.api_url, cam, command))
            else:
                logging.error("Invalid status for Camera %s", cam)

    def set_status_timestamp(self):
        """Adds a timestamp entry to the status attribute.
        """
        self.status["time"] = str(datetime.datetime.now())

    def run(self):
        """Runs startup functions and loops through get/save functions.
        """
        self.initialize_status()
        self.get_status_from_json()
        self.send_status_to_api()
        StatusKeeper.wait(INITIAL_WAIT_TIME)
        while True:
            self.get_status_from_api()
            self.log_status_to_json()
            StatusKeeper.wait(LOOP_TIME)

    @staticmethod
    def wait(time_):
        """Wraps the sleep function with logging.

        args:
            time (int): The amount of seconds to wait.
        """
        logging.info("Sleeping for %s seconds", time_)
        time.sleep(time_)
