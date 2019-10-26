"""Starts the status keeping daemon.
"""
import sys

from statuskeeper import StatusKeeper

if __name__ == "__main__":
    StatusKeeper(sys.argv[1], sys.argv[2], sys.argv[3])
