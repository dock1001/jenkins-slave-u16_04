// Based on 
// - https://getintodevops.com/blog/building-your-first-docker-image-with-jenkins-2-guide-for-developers
// - http://fishi.devtail.io/weblog/2016/11/20/docker-build-pipeline-as-code-jenkins/
node 
{
    // some basic config
    def IMAGE_PATH        = '.'
    def IMAGE_NAME        = 'dock1001/jenkins-slave'
    def IMAGE_TAG         = (env.BRANCH_NAME == 'master'  ? 'latest' : 'dev')
    def IMAGE_TAG_SHORT   = IMAGE_TAG.substring(0,1)
    def IMAGE_TAG_REV     = "${IMAGE_TAG_SHORT}${env.BUILD_NUMBER}"
    def PUSH_BUILD_NUMBER = (env.BRANCH_NAME == 'master')
    
    def app
    
    // Workaround a current issue with docker.withRegistry
    // https://issues.jenkins-ci.org/browse/JENKINS-38018 
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) 
    {
      sh 'docker login -u "$USERNAME" -p "$PASSWORD"'
    }      
    
    stage('Checkout SCM') 
    {
        // Let's make sure we have the repository cloned to our workspace
        checkout scm
    }

    stage('Build image') 
    {
        // This builds the actual image; synonymous to
        // docker build on the command line

        app = docker.build("${IMAGE_NAME}:${IMAGE_TAG_REV}", "${IMAGE_PATH}")
    }

    //stage('Test image') 
    //{
    //    // Ideally, we would run a test framework against our image.
    //    app.inside 
    //    {
    //        sh 'echo "Tests passed"'
    //    }
    //}

    stage('Push image') 
    {
        if (PUSH_BUILD_NUMBER)
        {
            app.push("${IMAGE_TAG_REV}")
        }
        app.push("${IMAGE_TAG}")
    }
}


// Finally, we'll push the image with two tags:
// First, the incremental build number from Jenkins
// Second, the 'latest' tag.
// Pushing multiple tags is cheap, as all the layers are reused.
//docker.withRegistry('', 'docker-hub-credentials')
//{
//  app.push("${IMAGE_TAG_REV}")
//}

