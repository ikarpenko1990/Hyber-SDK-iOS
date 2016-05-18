#!/bin/bash
jazzy -m Hyber \
--min-acl public \
-a "Global Message Services AG" \
-u https://gms-worldwide.com \
-o ./docs \
--module-version 0.0.1 \
--source-directory ./Hyber \
-x -workspace,Hyber.xcworkspace,-scheme,Hyber \
-c

jazzy -m Hyber \
--min-acl private \
-a "Global Message Services AG" \
-u https://gms-worldwide.com \
-o ./docs/privateDocs \
--module-version 0.0.1 \
--source-directory ./Hyber \
-x -workspace,Hyber.xcworkspace,-scheme,Hyber \
-c
