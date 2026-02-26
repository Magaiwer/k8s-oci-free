# 🚀 Terraform Modular OCI Kubernetes (Always Free)

> 🇧🇷 **Versão em Português / Portuguese version**: The Portuguese documentation can be found in [README_pt_BR.md](./README_pt_BR.md).

This repository contains a complete, modular, and best-practice ready template to create a native Kubernetes Cluster (OKE) within the limits of the Oracle Cloud Infrastructure (Always Free) tier.

---

## 🏗️ Architecture

The code provisions the following infrastructure:
- **Network (VCN and Public Subnets)**.
- **Security**: Firewall rules based on the Principle of Least Privilege (Security Lists configured only with necessary TCP/SSH ports).
- **Kubernetes Control Plane (API Master)**: A BASIC, cost-free cluster.
- **Compute (Worker Nodes)**: Configured exactly at Oracle's ARM free limits: `2 instances` (A1.Flex) providing `2 OCPUs` and `12GB of RAM` each.

---

## 🛠️ Prerequisites

1.  **Oracle Cloud Infrastructure (OCI) Account** with Always Free resources available.
2.  **Terraform CLI** installed on your workstation (Minimum version: 1.1.0).
3.  **Oracle API Keys configured** (Required to generate the *.pem* file used by Terraform to access your cloud).
4.  **OCI CLI** installed on your workstation to retrieve the `kubeconfig` after creation (Optional, but highly recommended).

---

## 🔑 How to fill out your Variables (terraform.tfvars)

To run this lab, you must create and fill out the variables file at the root of this project. We have provided a `terraform.tfvars.example` file. Rename or copy it to `terraform.tfvars`.

Here is where you can find each variable inside the Oracle Cloud web console:

- `tenancy_ocid`
  - **Where to find:** Top right corner, click on "Profile" (User icon) > `Tenancy: <your-tenancy-name>` > Copy the OCID.
- `user_ocid`
  - **Where to find:** Top right corner, click on "Profile" > `User Settings` > Copy your user's OCID (e.g., `ocid1.user.oc1...`).
- `private_key_path`
  - **Where to find/How to create:** In the OCI Console, under "Profile" > `User Settings` > In the bottom-left vertical menu, access `API Keys`. Add an API Key. Download the Private Key (`.pem`) and point this path to your local machine in the tfvars (e.g., `~/.oci/my_key.pem`).
- `fingerprint`
  - **Where to find:** After creating the "API Key" described above, the OCI window will display the Fingerprint (a hash like `12:34:56...`).
- `region`
  - **Where to find:** In the top-right bar is your Home Region (e.g., `sa-saopaulo-1` or `us-ashburn-1`). Only use regions that Oracle has granted you access to.
- `compartment_id`
  - **Where to find:** Access the Global menu in the top-left ☰ > `Identity & Security` > `Compartments`. Create a new one or copy the OCID of an existing Sandbox (It's recommended not to use the default root compartment for the cluster).
- `availability_domain`
  - **Where to find:** If you have doubts about what the ADs are called in your account, you can install and run the OCI CLI: `oci iam availability-domain list`. The name will be a string like `tYvX:US-ASHBURN-AD-1` or `rCvy:SA-SAOPAULO-1-AD-1`.

Other variables, like IP Ranges (CIDR Blocks) or the K8s version (`v1.31.1`), can be kept at their suggested defaults unless you need to inject specific corporate routing.

---

## 🏃 How to Deploy the Cluster

Open your favorite terminal and follow these steps:

**1. Set up your base (Download plugins and modules)**
```bash
terraform init
```

**2. Preview Changes (Optional, but recommended)**
```bash
terraform plan
```
> Review to ensure no unexpected costs (like a NAT Gateway) appear. If resources don't match the Always Free tier, abort the execution. The native script prioritizes everything that is free.

**3. Create Resources**
```bash
terraform apply
```
> Confirm with "yes". After approval, Oracle will take around ~10 to ~25 minutes to provision the Cluster. Go grab a coffee. ☕

**4. Accessing your New Cluster!**
After a successful `apply`, the terminal will display a special output called `kubeconfig_command`.

To actually access the cluster, you will need two tools on your machine:
1. **OCI CLI**: If you don't have it, you can install the official script with the command `bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"`
2. **Kubectl**: The official Kubernetes tool. (Follow the [k8s documentation](https://kubernetes.io/docs/tasks/tools/) for your OS).

With the tools installed, copy the command generated in the Terraform Output. It will look like this:
```bash
oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.xxxx --file $HOME/.kube/config --region sa-saopaulo-1 --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```
Execute it in your terminal to download your secure credentials file. Once done, connect by running the master command: `kubectl get nodes` and see your Worker nodes ready for fun! 🎉

---

## 🗑️ Destruction / Cleanup

Oracle may suspend inactive accounts (`Idle status`). If you need to easily remove all created resources, run:
```bash
terraform destroy
```

Done cleanly, following Componentization principles to avoid virtual clutter. Have fun!

---

## 🧩 Optional Add-ons and Observability

This repository has been expanded to support advanced Cloud-Native tools, keeping them **COMPLETELY OPTIONAL** via `Feature Flags`. Cluster and Network (Cloud Provider) management remains strictly isolated from Kubernetes/Helm installations.

In your `terraform.tfvars`, you can inject the following flags (if omitted, the default is `false`):

```hcl
enable_headlamp   = true   # Installs Headlamp Management UI
enable_monitoring = true   # Installs Kube-Prometheus-Stack (Prometheus, Grafana, Alertmanager)
enable_telemetry  = false  # Installs Loki (Centralized Logs) and OpenTelemetry Collector
```

Once these variables are changed and you run `terraform apply`, the script will automatically provision via containers and Helm Charts using the recently generated credentials from your local Kubeconfig.

### 🌐 Accessing Headlamp UI

Since Headlamp is installed via NodePort, you have two ways to access it:

**Option 1: Quick Access (Port Forwarding)**
Run this command in your terminal:
```bash
kubectl -n kube-system port-forward svc/headlamp 8080:80
```
Then open `http://localhost:8080` in your browser.

**Option 2: Direct Access (NodePort)**
1. Find the assigned port: `kubectl -n kube-system get svc headlamp`
2. Find your Node's Public IP: `kubectl get nodes -o wide`
3. Access via: `http://<NODE_PUBLIC_IP>:<NODEPORT>`

**Authentication (Admin Token)**
To log in, you will need a token. Run these commands to create an admin service account and get its token (you can ignore "already exists" errors):
```bash
# 1. Create service account
kubectl create serviceaccount headlamp-admin -n kube-system

# 2. Give it cluster-admin permissions
kubectl create clusterrolebinding headlamp-admin-role --clusterrole=cluster-admin --serviceaccount=kube-system:headlamp-admin

# 3. Generate the token (Run this whenever you need to login)
kubectl create token headlamp-admin -n kube-system
```
Copy the generated token from step 3 and paste it into the Headlamp login screen.

### ⚠️ Resource Estimates (Consumption when Activating the Full Stack)

If you activate **all 3 flags as `true`**, this will be the approximate idle consumption required by the entire stack running on your 2 Worker Nodes (which together total **4 OCPUs and 24 GB of RAM** in the Always Free tier):

1. **Headlamp**: It is a lightweight GUI built on a very slim baseline.
   - *Average Base Consumption*: **~100 to 150 MB of RAM** and steady ~0.1 OCPU.
2. **Kube-Prometheus-Stack (Grafana + Alertmanager + Prometheus)**: 
   - *Average Base Consumption*: **~1.5 to 2 GB of RAM** and ~0.4 OCPU (Ingesting few metrics initially).
3. **Loki + OpenTelemetry (Promtail)**: 
   - *Average Base Consumption*: **~800 MB to 1.2 GB of RAM** and ~0.3 OCPUs (Extra attention required as disk logs also consume Block Storage vertices).

#### **Total Hidden Cost of the "Everything Activated" System**
- **RAM Utilized:** Launching this entire cutting-edge suite will immediately consume **between 3 GB to 5 GB of your total available RAM** (which is currently 24 GB total, meaning ~15% to ~25% of memory spent). This leaves a comfortable ~19 GB of RAM free to run your user microservices.
- **CPU Utilized:** It will cost around **0.8 OCPUs** from a total limit of 4 at base. If user or metric ingestion increases, the Go processes (Prometheus/Loki) will scale this usage.

> **💡 Tip:** Avoid activating Heavy Logging tools (Loki) if you plan to manage few applications (1 Cluster) free from massive observability. `Headlamp + Grafana` forms the best "Cost-Benefit" adoption in a closed OCI Free ecosystem.
