#!/bin/bash

sudo killall open-fprintd
sudo systemctl kill python3-validity
sleep 1
sudo systemctl start python3-validity
sleep 1
