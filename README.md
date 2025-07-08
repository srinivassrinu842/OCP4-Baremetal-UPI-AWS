# OpenShift 4 BareMetal UPI on AWS (Terraform)

This project provides a complete, production-grade, two-stage Terraform automation for deploying an OpenShift 4 BareMetal UPI cluster on AWS, following best practices and the reference architecture described at [blackhatinside.com](https://blackhatinside.com/2024/08/10/how-to-create-openshift-4-baremetal-upi-cluster-on-aws/).

---

## Architecture Diagram

```mermaid
flowchart TD
    VPC["VPC 10.0.0.0/16"]
    subgraph AZ_A["Availability Zone A"]
      PUB1["Public Subnet 1"]
      NAT1["NAT Gateway 1"]
      BASTION["Bastion EC2"]
      PRIV1["Private Subnet 1"]
      BOOTSTRAP["Bootstrap"]
      MASTER1["Master 1"]
      WORKER1["Worker 1"]
    end
    subgraph AZ_B["Availability Zone B"]
      PUB2["Public Subnet 2"]
      NAT2["NAT Gateway 2"]
      PRIV2["Private Subnet 2"]
      MASTER2["Master 2"]
      WORKER2["Worker 2"]
    end
    subgraph AZ_C["Availability Zone C"]
      PUB3["Public Subnet 3"]
      NAT3["NAT Gateway 3"]
      PRIV3["Private Subnet 3"]
      MASTER3["Master 3"]
    end
    IGW["Internet Gateway"]
    NLB["Network Load Balancer\n(Listeners: 6443, 22623, 80, 443)"]
    S3["S3 Bucket (public, ignition)"]
    S3EP["S3 Endpoint"]
    R53["Route53 Private Hosted Zone"]

    VPC --> IGW
    VPC --> S3EP
    VPC --> R53
    VPC --> S3
    VPC --> AZ_A
    VPC --> AZ_B
    VPC --> AZ_C

    PUB1 --> IGW
    PUB2 --> IGW
    PUB3 --> IGW
    PUB1 --> NAT1
    PUB2 --> NAT2
    PUB3 --> NAT3
    PUB1 --> BASTION
    PRIV1 --> NAT1
    PRIV2 --> NAT2
    PRIV3 --> NAT3
    PRIV1 --> BOOTSTRAP
    PRIV1 --> MASTER1
    PRIV1 --> WORKER1
    PRIV2 --> MASTER2
    PRIV2 --> WORKER2
    PRIV3 --> MASTER3
    NLB --> PRIV1
    NLB --> PRIV2
    NLB --> PRIV3
    BOOTSTRAP --> NLB
    MASTER1 --> NLB
    MASTER2 --> NLB
    MASTER3 --> NLB
    WORKER1 --> NLB
    WORKER2 --> NLB
    S3EP --> S3
    BOOTSTRAP --> S3
    MASTER1 --> S3
    MASTER2 --> S3
    MASTER3 --> S3
    WORKER1 --> S3
    WORKER2 --> S3
    BOOTSTRAP --> R53
    MASTER1 --> R53
    MASTER2 --> R53
    MASTER3 --> R53
    WORKER1 --> R53
    WORKER2 --> R53
```

> **Figure: OpenShift 4 BareMetal UPI on AWS Architecture**  
> _Based on [blackhatinside.com: How to create an OpenShift 4 BareMetal UPI Cluster on AWS?](https://blackhatinside.com/2024/08/10/how-to-create-openshift-4-baremetal-upi-cluster-on-aws/)_

---

## Project Structure & Workflow

- **infra/**: Provisions all base AWS infrastructure (VPC, subnets, NAT, S3, NLB, Route53, bastion, etc.)
- **openshift_nodes/**: Provisions OpenShift bootstrap, master, and worker nodes, and manages NLB target group registration.

### **Deployment Steps**
1. Deploy `infra/` first. Use its outputs for the next stage.
2. SSH to the bastion host and follow the steps in `infra/BASTION_SETUP_STEPS.md` to prepare ignition configs and upload to S3.
3. Deploy `openshift_nodes/` to create the OpenShift nodes and register them with the NLB.

---

## Reference
- [How to create an OpenShift 4 BareMetal UPI Cluster on AWS? (blackhatinside.com)](https://blackhatinside.com/2024/08/10/how-to-create-openshift-4-baremetal-upi-cluster-on-aws/) 