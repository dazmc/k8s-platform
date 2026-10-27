    # Cluster Inventory

    ## Production Clusters

    ### Azure AKS (East US)
    - **Name:** aks-prod-eastus
    - **Version:** 1.28.x
    - **Node Pools:**
      - system (3 nodes, Standard_D2s_v5)
      - app (10 nodes, Standard_D4s_v5, auto-scale 10-20)
      - spot (5 nodes, Standard_D4s_v5 spot, auto-scale 0-10)
    - **Addons:** Monitoring, Ingress, CNI Overlay
    - **Network:** Azure CNI, 10.0.0.0/8
    - **Backup:** Daily snapshots to blob storage

    ### AWS EKS (us-east-1)
    - **Name:** eks-prod-us-east-1
    - **Version:** 1.28.x
    - **Node Groups:**
      - on-demand (5 nodes, t3.xlarge)
      - spot (10 nodes, t3.xlarge, spot pricing)
    - **Addons:** VPC CNI, EBS CSI, CoreDNS
    - **Network:** VPC 10.1.0.0/8, multi-AZ
    - **Backup:** Velero backups to S3

    ## Staging Clusters

    ### Single-node GKE (us-central1)
    - **Name:** gke-staging-us-central1
    - **Version:** 1.28.x
    - **Nodes:** 1 (n1-standard-2)
    - **Network:** VPC 10.2.0.0/8
    - **Cost:** ~$150/month

    ## Quick Actions

    ```bash
    # Switch context
    kubectl config use-context aks-prod-eastus
    kubectl config use-context eks-prod-us-east-1
    kubectl config use-context gke-staging-us-central1

    # Useful aliases (add to ~/.bashrc or ~/.zshrc)
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgn='kubectl get nodes'
    alias kd='kubectl describe'
    alias kl='kubectl logs'
    ```
