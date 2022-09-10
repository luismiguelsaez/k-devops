

## BUILD IMAGE

- Building in MacOS with M1 ARM processor
- Check signature: https://download.litecoin.org/README-HOWTO-GPG-VERIFY-TEAM-MEMBERS-KEY.txt
  - Spent a lot of time verifying the GPG signature, because the server was unresponsive and failing, so I included the PGP file in the repo as `FE3348877809386C.gpg` to import it from file. In the code, I kept the commands to download the signature during the image build.
- Local build commands ( for testing )
  ```bash
  docker build --build-arg PKG_VERS=0.18.1 -t luismiguelsaez/litecoind:0.18.1 .
  docker push luismiguelsaez/litecoind:0.18.1
  trivy image -s critical,high luismiguelsaez/litecoind:0.18.1
  ```

## K8s resources

- Set container limits based on resources usage while running the image locally
- Using `standard` storage class for testing; in cloud environments, proper CSI driver storage class must be used, like EBS for AWS/EKS clusters
- Added additional config
  - livenessProbe
  - securityContext
- Testing cluster
  ```bash
  minikube start --kubernetes-version=1.23.9 --driver=docker --nodes=1 --cpus max --memory=2048m --container-runtime=containerd
  ```
- Deployment
  ```bash
  kubectl apply -f k8s/statefulset.yaml
  ```

## CICD pipeline

- Used official Jenkins docs: https://www.jenkins.io/doc/book/pipeline/syntax
- Although the best way to deploy in K8s is with Gitops tools like ArgoCD, this time we are going to deploy from the same Jenkins pipeline, as required
- This pipeline requires several plugins thst we are assuming are already installed
- We are using Jenkins credentials for DockerHUB
- The pipeline must be executed in a Docker node, so we are specifying it in the `label`. The node must have the following tools installed:
  - `docker` ( engine and CLI )
  - `trivy`
  - `kubectl`
  - `aws-cli`
- Instead of `parameters`, we are using `environment` to set the build variables, just to make it simpler
- In this example, we assume the cluster is deployed in AWS/EKS service

## Terraform

- Used AWS provider docs: https://registry.terraform.io/providers/hashicorp/aws%20%20/4.30.0
- AWS authentication is done through profiles stored in `.aws/credentials` and exporting `AWS_PROFILE` variable before executing the commands
- Added IAM keys for the user, so we can test the config
- I understand that the role hasn't any attached policy, for instance, for the users to be able to write to a S3 bucket; so this example is only intended to show how to create a role assumable by any user in AWS account

## Script kiddies

In this example, we need to replace the name of the references to S3 objects in a DB, after a migration from a legacy bucket

- Old names: `https://racooncity-app-assets.s3.eu-central-1.amazonaws.com/screenshots/1000202761e6965aa468e8.62494197/f5183371ef3740211f604a0714954e5394624561.jpg`
- New names: `https://umbrellacorp-app-assets.s3.eu-west-1.amazonaws.com/files/screenshots/1000202761e6965aa468e8.62494197/f5183371ef3740211f604a0714954e5394624561.jpg`

- The code would look like this

```bash
echo "https://racooncity-app-assets.s3.eu-central-1.amazonaws.com/screenshots/1000202761e6965aa468e8.62494197/f5183371ef3740211f604a0714954e5394624561.jpg" | awk '
  /https:\/\/racooncity-app-assets.s3.eu-central-1.amazonaws.com\/screenshots\/[a-f0-9]{22}.*.[a-f0-9]{8}\/[a-f0-9]+.jpg.*/{
    split($1,a,"/")
    bucket_url_old=a[3]
    bucket_url_new="umbrellacorp-app-assets.s3.eu-west-1.amazonaws.com"
    project_id=a[5]
    file=a[6]
    printf("https://%s/files/screenshots/%s/%s",bucket_url_new,project_id,file)
  }
'
```

It matches the old format and converts to the new one, with a different bucket name, region and path
