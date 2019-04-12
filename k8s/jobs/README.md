# Restore Jobs

WARNING: These restore the latest snapshot to the target environment.
         Running one of these will "revert" persistent volumes to their
         last known state.


## Running a restore

kubectl apply -f name-restore-job.yml
kubectl get pod
kubectl logs name-restore-XXXX
