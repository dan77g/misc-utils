#!/bin/bash
sudo rfcomm show -a
sudo rfcomm release -a
sudo rfcomm bind 00:21:09:D9:9D:22
sudo rfcomm show -a

