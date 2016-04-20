#!/bin/bash

kong start && tail -f /usr/local/kong/serf.log
