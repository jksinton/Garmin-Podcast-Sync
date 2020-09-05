#!/bin/bash

# dynamic mount
gio mount -li | grep mtp | awk -F= '{print $2}' | xargs -I {} gio mount {}
