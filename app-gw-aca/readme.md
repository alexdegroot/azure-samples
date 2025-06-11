## Azure Resource Deployment Guide

### Combined
First make sure to login
```bash
az login
```

Then:
```bash
LOCATION='westeurope'
GROUPNAME='rg-minibank-ztdemo'
az group create -n $GROUPNAME -l $LOCATION
az deployment group create --resource-group $GROUPNAME --template-file main.bicep
```
Note: The entire script is based on random ids which should make things a lot easier.