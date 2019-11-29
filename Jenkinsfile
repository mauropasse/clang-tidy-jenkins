node {
    // Clone the repo
    checkout scm

    // Stage 1
    try
    {
        stage('Build') {
            sh '''
                 bash scripts/build.sh
            '''
        }
    }
    catch(e)
    {
        echo e.toString()
    }

    // Stage 2
    try
    {
        stage('Run clang-tidy') {
            sh '''
                 bash scripts/clang-tidy-jenkins.sh
            '''
        }
    }
    catch(e)
    {
        echo e.toString()
    }

    // Stage 3
    try
    {
        stage('JUnit') {
            junit '*junit.xml'
        }
    }
    catch(e)
    {
        echo e.toString()
    }
}
