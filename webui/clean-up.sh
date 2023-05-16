#!/bin/bash

oc delete builds webui-1
oc delete buildconfig webui
oc delete imagestream webui
oc delete deployment webui
oc delete service webui
oc delete route webui
