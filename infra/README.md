## First time setup
1. Install gcloud sdk and terraform

2. Initialize and Authenticate google cloud sdk
$ gcloud init

3. gcloud auth application-default login

4. Plan and apply terraform
TF_VAR_project=mentorapp-325205 TF_VAR_region=asia-south1 TF_VAR_zone=asia-south1-a terraform plan
TF_VAR_project=mentorapp-325205 TF_VAR_region=asia-south1 TF_VAR_zone=asia-south1-a terraform apply

5. After cluster creation, configure kubectl to access cluster
gcloud container clusters get-credentials mentorapp --zone asia-south1-a --project mentorapp-325205
