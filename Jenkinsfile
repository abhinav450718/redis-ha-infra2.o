pipeline {
    agent any

    environment {
        AWS_REGION  = "sa-east-1"
        TF_DIR      = "terraform"
        ANSIBLE_DIR = "ansible"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo "Code checkout successful."
            }
        }

        stage('Terraform Apply (Auto)') {
            steps {
                dir(TF_DIR) {
                    withCredentials([
                        [$class: 'UsernamePasswordMultiBinding',
                         credentialsId: 'aws-creds',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                          terraform init -input=false
                          terraform fmt -recursive || true
                          terraform validate

                          terraform plan -out=tfplan -var="aws_region=$AWS_REGION"
                          terraform apply -auto-approve tfplan

                          terraform output -json > ../terraform_outputs.json
                          terraform output -raw private_key_pem > ../redis-ha-key.pem
                        '''
                    }
                }
            }
        }

        stage('Install AWS Python SDK (for dynamic inventory)') {
            steps {
                dir(ANSIBLE_DIR) {
                    sh '''
                      pip3 install boto3 botocore --break-system-packages
                    '''
                }
            }
        }

        stage('Test Dynamic Inventory') {
            steps {
                dir(ANSIBLE_DIR) {
                    withCredentials([
                        [$class: 'UsernamePasswordMultiBinding',
                         credentialsId: 'aws-creds',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                          export AWS_REGION='sa-east-1'
                          export SSH_KEY="$WORKSPACE/redis-ha-key.pem"

                          ansible-inventory -i inventory/aws_ec2.yml --graph
                        '''
                    }
                }
            }
        }

        stage('Configure Redis via Ansible') {
            steps {
                dir(ANSIBLE_DIR) {
                    withCredentials([
                        [$class: 'UsernamePasswordMultiBinding',
                         credentialsId: 'aws-creds',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                          export AWS_REGION='sa-east-1'
                          export SSH_KEY="$WORKSPACE/redis-ha-key.pem"
                          export ANSIBLE_HOST_KEY_CHECKING=False

                          ansible-playbook \
                            -i inventory/aws_ec2.yml \
                            redis_cluster.yml
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Redis HA deployed successfully!"
        }
        failure {
            echo "❌ Pipeline failed — check logs."
        }
    }
}
