# OpenShift Bastion Host Setup Steps

Once your bastion host is up and accessible via its public IP, follow these steps to prepare for OpenShift UPI installation:

## 1. SSH to the Bastion Host

```sh
ssh -i <path-to-your-ssh-key> ec2-user@<bastion-public-ip>
```

## 2. Download and Install OpenShift CLI and Installer

```sh
# Download OpenShift CLI
wget -c https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.16.5/openshift-client-linux-amd64-rhel8-4.16.5.tar.gz

# Extract and install
tar -xf openshift-client-linux-amd64-rhel8-4.16.5.tar.gz
sudo mv oc /usr/local/bin/
rm -f openshift-client-linux-amd64-rhel8-4.16.5.tar.gz README.md kubectl

# Check version
oc version

# Download OpenShift Installer
wget -c https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.16.5/openshift-install-linux-4.16.5.tar.gz

# Extract and install
tar -xf openshift-install-linux-4.16.5.tar.gz
sudo mv openshift-install /usr/local/bin/
rm -f openshift-install-linux-4.16.5.tar.gz README.md

# Check version
openshift-install version
```

## 3. Generate SSH Key for OpenShift

```sh
ssh-keygen -N '' -f ~/.ssh/ssh-aws.key -q <<< y > /dev/null
```

## 4. Prepare OpenShift Install Directory

```sh
mkdir -p ~/OCP4
```

## 5. Create install-config.yaml

- Create `~/OCP4/install-config.yaml` with your cluster details, pull secret, and SSH public key.
- Example:

```yaml
apiVersion: v1
baseDomain: <your-domain>
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: <cluster-name>
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
fips: false
pullSecret: '<your-pull-secret>'
sshKey: '<contents-of-~/.ssh/ssh-aws.key.pub>'
```

## 6. Generate Manifests and Ignition Configs

```sh
cd ~/OCP4
openshift-install create manifests --dir=.
openshift-install create ignition-configs --dir=.
```

## 7. (Optional) Configure AWS CLI and Upload Ignition to S3

```sh
# Install AWS CLI if not present
sudo yum install -y awscli

# Configure AWS CLI (if not already configured)
aws configure

# Upload bootstrap ignition file to S3
aws s3 cp ~/OCP4/bootstrap.ign s3://<your-s3-bucket-name> --acl public-read
```

## 8. Create merge-bootstrap.ign

- Create `~/OCP4/merge-bootstrap.ign` with the following content (update the S3 URL):

```json
{
  "ignition": {
    "config": {
      "merge": [
        {
          "source": "https://<your-s3-bucket-name>.s3.amazonaws.com/bootstrap.ign",
          "verification": {}
        }
      ]
    },
    "timeouts": {},
    "version": "3.2.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}
```

---

**You are now ready to proceed with the OpenShift UPI installation!** 