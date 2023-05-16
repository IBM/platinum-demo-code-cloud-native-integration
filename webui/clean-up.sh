#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2023. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

oc delete builds webui-1
oc delete buildconfig webui
oc delete imagestream webui
oc delete deployment webui
oc delete service webui
oc delete route webui
