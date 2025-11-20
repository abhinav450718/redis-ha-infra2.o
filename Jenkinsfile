pipeline {
    agent any

    environment {
        AWS_REGION   = "sa-east-1"
        TF_DIR       = "terraform"
        ANSIBLE_DIR  = "ansible"
        SCRIPTS_DIR  = "scripts"
        PRIVATE_KEY  = "/var/lib/jenkins/redis-ha-key.pem"
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
                            terraform init -input=false -reconfigure
                            terraform fmt -recursive || true
                            terraform validate

                            terraform plan -out=tfplan -var="aws_region=$AWS_REGION"
                            terraform apply -auto-approve tfplan
                        '''

                        // save key to Jenkins host
                        sh '''
                            terraform output -raw private_key_pem > $PRIVATE_KEY
                            chmod 600 $PRIVATE_KEY
                        '''
                    }
                }
            }
        }

        stage('Install AWS Python SDK (boto3)') {
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
                            export SSH_KEY=$PRIVATE_KEY
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
                            export SSH_KEY=$PRIVATE_KEY
                            export ANSIBLE_HOST_KEY_CHECKING=False

                            ansible-playbook -i inventory/aws_ec2.yml redis_cluster.yml
                        '''
                    }
                }
            }
        }

        stage('Verify Redis Replication') {
            steps {
                dir(SCRIPTS_DIR) {
                    sh '''
                        chmod +x verify_redis.sh
                        ./verify_redis.sh $PRIVATE_KEY
                    '''
                }
            }
        }
    }

    post {
        success { echo "🎉 Redis HA deployed successfully!" }
        failure { echo "❌ Pipeline failed — check logs." }
    }
}
