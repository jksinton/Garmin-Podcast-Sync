#!/bin/bash

# dynamic unmount
gio mount -li | grep "mtp ->" | awk -F'-> ' '{print $2}' | xargs -I {} gio mount -u {}
