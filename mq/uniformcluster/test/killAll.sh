#!/bin/bash

kill $(ps -e | grep -v grep | grep amqsphac | awk '{print $1}')
kill $(ps -e | grep -v grep | grep amqsghac | awk '{print $1}')

