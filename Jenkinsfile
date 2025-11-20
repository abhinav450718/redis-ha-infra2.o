pipeline {
    agent any

    environment {
        AWS_REGION   = "sa-east-1"
        TF_DIR       = "terraform"
        ANSIBLE_DIR  = "ansible"
        SCRIPTS_DIR  = "scripts"
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
                    withCredentials([[
                        $class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'aws-creds',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {

                        sh '''
                          terraform init -input=false
                          terraform fmt -recursive || true
                          terraform validate

                          terraform plan -out=tfplan -var="aws_region=$AWS_REGION"
                          terraform apply -auto-approve tfplan
                          terraform output -json > ../terraform_outputs.json
                        '''
                    }
                }
            }
        }

        stage('Install AWS Python SDK') {
            steps {
                dir(ANSIBLE_DIR) {
                    sh '''
                      pip3 install boto3 botocore --break-system-packages
                      echo "✓ boto3 & botocore installed"
                    '''
                }
            }
        }

        stage('Test Dynamic Inventory') {
            steps {
                dir(ANSIBLE_DIR) {
                    withCredentials([[
                      $class: 'UsernamePasswordMultiBinding',
                      credentialsId: 'aws-creds',
                      usernameVariable: 'AWS_ACCESS_KEY_ID',
                      passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                          export AWS_REGION=sa-east-1
                          ansible-inventory -i inventory/aws_ec2.yml --list
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
                        sshUserPrivateKey(credentialsId: 'redis-ssh-key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'UsernamePasswordMultiBinding',
                         credentialsId: 'aws-creds',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                          export ANSIBLE_HOST_KEY_CHECKING=False
                          export SSH_KEY=$SSH_KEY
                          export AWS_REGION=sa-east-1

                          ansible-playbook \
                            -i inventory/aws_ec2.yml \
                            redis_cluster.yml \
                            --private-key "$SSH_KEY"
                        '''
                    }
                }
            }
        }

        stage('Verify Redis Replication') {
            steps {
                dir(SCRIPTS_DIR) {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'redis-ssh-key', keyFileVariable: 'SSH_KEY')
                    ]) {

                        sh '''
                          chmod +x verify_redis.sh
                          ./verify_redis.sh "$SSH_KEY"
                        '''
                    }
                }
            }
        }
    }

    post {
        success { echo "🎉 Redis HA deployed successfully!" }
        failure { echo "❌ Pipeline failed — check logs." }
    }
}
