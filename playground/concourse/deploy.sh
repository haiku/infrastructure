#!/bin/bash

# Create-team also logs in.
./create-team.sh test continuous
./create-team.sh test nightly
./create-team.sh test r1beta1

# Deploy pipelines
./apply-pipeline.sh continuous master minimal secrets.source
./apply-pipeline.sh nightly r1beta1 nightly secrets.source
./apply-pipeline.sh r1beta1 r1beta1 release secrets.source
