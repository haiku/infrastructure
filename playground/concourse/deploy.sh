#!/bin/bash

# Create-team also logs in.
fly -t continuous status
if [[ $? -ne 0 ]]; then
	./create-team.sh test continuous
fi

fly -t r1beta1 status
if [[ $? -ne 0 ]]; then
	./create-team.sh test r1beta1
fi

# Deploy pipelines
./apply-pipeline.sh continuous master secrets.source
./apply-pipeline.sh r1beta1 r1beta1 secrets.source
