pipeline {
    agent any

    environment {
        AWS_REGION        = "sa-east-1"
        TF_DIR            = "terraform"
        ANSIBLE_DIR       = "ansible"
        SCRIPTS_DIR       = "scripts"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo "Repo checked out successfully."
            }
        }

        stage('Terraform Init & Plan') {
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
                          terraform plan -out=tfplan -input=false \
                            -var="aws_region=$AWS_REGION"
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    input message: 'Approve Terraform apply?', ok: 'Apply'
                }

                dir(TF_DIR) {
                    withCredentials([
                        [$class: 'UsernamePasswordMultiBinding',
                         credentialsId: 'aws-creds',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                          terraform apply -input=false tfplan
                          terraform output -json > ../terraform_outputs.json
                        '''
                    }
                }
            }
        }

        stage('Install Ansible Roles & Show Inventory') {
            steps {
                dir(ANSIBLE_DIR) {
                    sh '''
                      ansible-galaxy install -r requirements.yml
                      ansible-inventory -i inventory/aws_ec2.yml --graph
                    '''
                }
            }
        }

        stage('Configure Redis with Ansible') {
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
                          chmod +x ../scripts/generate_inventory.sh
                          chmod +x ../scripts/verify_redis.sh

                          export ANSIBLE_HOST_KEY_CHECKING=False

                          ansible-playbook \
                            -i inventory/aws_ec2.yml \
                            redis_cluster.yml \
                            --private-key "$SSH_KEY" \
                            -e aws_region=$AWS_REGION
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
                          ./verify_redis.sh "$SSH_KEY"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Redis HA Deployment Completed Successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
        always {
            archiveArtifacts artifacts: 'terraform_outputs.json', onlyIfSuccessful: true
        }
    }
}
