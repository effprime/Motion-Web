"""Starts the status keeping daemon.
"""
import sys

from statuskeeper import StatusKeeper

StatusKeeper(sys.argv[1], sys.argv[2])
