pipeline {
	agent any
    environment {
        PATH = "${PATH}:${getTerraformPath()}"
    }
    stages{
        // stage('terraform init'){
        //     steps {
        //         sh "terraform init"
        //     }
        // } 
        // stage('terraform plan'){
        //     steps {
        //         sh "terraform plan"
        //     }
        // }
        // stage('terraform apply'){
        //     steps {
        //         sh "terraform apply -auto-approve"
        //     }
        // }
        stage('terraform destroy'){
            steps {
                sh "terraform destroy -auto-approve"
            }
        }
    }
}

def getTerraformPath(){
    def tfHome= tool name:'terraform-40',type:'terraform'
    return tfHome
}