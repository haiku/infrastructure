#!/bin/bash

# Create-team also logs in.
./create-team.sh test continious
./create-team.sh test r1beta1

# Deploy pipelines
./apply-pipeline.sh continious master secrets.source
./apply-pipeline.sh r1beta1 r1beta1 secrets.source
