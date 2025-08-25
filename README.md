🚀 How I Deployed a GKE Cluster and Workloads Using Terraform

I’ve been working on setting up a Google Kubernetes Engine (GKE) cluster using Terraform. What started as a simple infrastructure setup turned into a full learning experience with authentication, state management, and security best practices.



🔹 Step 1: Setting the Foundation

1. Build a custom VPC and subnetwork.

2. Set up firewall rules for internal and external communication.

3. Provision a GKE cluster with a managed node pool.

4. Connect to the GKE cluster and deploy a sample Nginx application directly using Terraform.

5. Store Terraform state remotely in a GCS bucket for collaboration.



🔹 Step 2: Deploying Applications via Terraform

Once the cluster was up and running, I wanted to test workloads. Instead of manually deploying with kubectl, I used the Terraform Kubernetes provider to define:

1. A Pod (running Nginx)

2. A LoadBalancer Service (to expose it externally)

Terraform gave me an external IP at the end, and the Nginx page was accessible in the browser 🎉.

👉 Key takeaway: Terraform can manage both infrastructure and workloads on Kubernetes.



🔹 Step 3: Service Account Security

 The service account management is important. These keys are as sensitive as passwords, and mishandling them can expose your entire cloud project.

Here’s the correct approach:

Create a dedicated service account with only required roles:

roles/container.admin (manage GKE)

roles/compute.networkAdmin (VPC, subnets, firewalls)

roles/iam.serviceAccountUser (workload identity binding)

roles/storage.objectUser (Terraform state in GCS)

Generate a private key (JSON format).

Download and store securely — once lost, it can’t be recovered.

Place the file in your Terraform project folder, but never commit it to GitHub. Add it to .gitignore.

For CI/CD pipelines (e.g., Jenkins, GitHub Actions), inject the credentials dynamically from a secret manager.

👉 Long-term: consider Workload Identity Federation to avoid long-lived keys altogether.



🔹 Step 4: Remote State Management

To collaborate safely, I configured Terraform’s remote state backend in a GCS bucket.

This ensures:

Everyone works off the same state file.

No accidental overwrites.

Better team collaboration.



Here’s how I structured my Terraform project for clarity and scalability:

gke-project/

├── backend.tf         # Remote state configuration (GCS backend)

├── main.tf            # VPC, Subnet, Firewall rules, GKE Cluster, Node Pool

├── provider.tf        # Google provider config (project, region, zone, credentials)

├── variables.tf       # Input variables (project-id, region, zone, k8s version)

├── k8s.tf             # Kubernetes resources (Pod + Service definitions)

├── key.json           # Service Account key (secure, never committed)



Repo Link: https://github.com/Yashaswini-Vuppu/gke-with-terraform/



#Terraform #GKE #GoogleCloud #Kubernetes #DevOps

#InfrastructureAsCode #Security
