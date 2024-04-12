# Notes

## Steps for checking logs and changing logging levels.

1. Identify the Pod that has the pipeline running. 

    First, you need to know the pod name that you want to check logs for. If you already know the pod name, skip to Step 2. Otherwise, list all pods in a specific namespace

    ```bash
    kubectl get pods --namespace=<namespace>
    ```
2. View Logs

    To view the logs of the pod, use the following command:

    ```bash
    kubectl logs <pod-name> --namespace=<namespace>
    ```

    If you want to continuously monitor the logs of the pod, you can add the -f or --follow flag to the kubectl logs command:
    ```bash
    kubectl logs -f <pod-name> --namespace=<namespace>
    ```

## Steps for checking cluster health

- Inspect Node Conditions
    To get more detailed information on nodes’ conditions, you can describe each node:
    ```bash
    kubectl describe node <node-name>
    ```
    Replace `<node-name>` with the name of the node. Look for conditions like DiskPressure, MemoryPressure, PIDPressure, and NetworkUnavailable to ensure they are all False, which indicates no issues.

- Check Workloads Health
    Check the health of all deployments, stateful sets, and other workloads:
    ```bash
    kubectl get all --all-namespaces
    ```
    This command lists all resources across all namespaces, allowing you to quickly see if any pods are in an Error or CrashLoopBackOff state.

- Review Events and Logs
    To identify issues or events that might affect the health of the cluster:
    ```bash
    kubectl get events --sort-by='.lastTimestamp' --all-namespaces
    ```

## Steps for visualization and further customization for use-case specific changes
To proceed with further customization that fits your use-case, please begin process of contacting ClearObject/Google under private offer.