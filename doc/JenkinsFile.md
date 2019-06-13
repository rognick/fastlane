# Groovy JenkinsFile


[Pipeline Syntax](https://jenkins.io/doc/book/pipeline/syntax/)

```
#!groovy

properties([
  [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
  parameters([
        booleanParam(defaultValue: true, description: 'Allow you to organize your testers and manage who receives specific versions of your app', name: 'Collaborators'),
        booleanParam(defaultValue: true, description: 'Allow you to organize your testers and manage who receives specific versions of your app', name: 'QA_Team'),
        booleanParam(defaultValue: false, description: 'Allow you to organize your testers and manage who receives specific versions of your app', name: 'BA_Team'),
        string(defaultValue: 'New Release', description: 'Release notes', name: 'RELEASE_NOTES', trim: false),
        booleanParam(defaultValue: true, description: 'Appcenter add Changelogs to Release notes', name: 'CHANGELOG')
      ])
  ])

pipeline {
  agent any
  environment {
    LC_ALL   = 'en_US.UTF-8'
    LANG     = 'en_US.UTF-8'
    LANGUAGE = 'en_US.UTF-8'
  }

  stages {

    stage('Enviroment Install') {
      steps {
        parallel (
          "Pod Install": {
            sh 'pod install'
          },
          "Bundle Install": {
            // sh 'bundle install'
            sh 'echo'
          },
          "Fetch tags": {
            sh 'git tag -l | xargs git tag -d'
            sh 'git fetch --tags'
          }
        )
      }
    }

    stage('Clear data and folders') {
      steps {
        sh 'fastlane clear_data'
      }
    }

    stage('Build App') {
      steps {
        sh "fastlane build_development"
      }
    }

    stage('Upload to App Center') {
      steps {
        script {
          def group = "Collaborators"
          if (params.QA_Team) {
            group = group + ",QA_Team"
          }
          if (params.BA_Team) {
            group = group + ",BA_Team"
          }
          sh "fastlane upload_to_appcenter group:\"${group}\" info:\"${params.RELEASE_NOTES}\" changelog:${params.CHANGELOG}"
        }
      }
    }

    stage('Push to Git tags/commit') {
      steps {
        sh "fastlane push_to_git_tags_and_commit"
      }
    }

  }

  post {
    success {
      archiveArtifacts 'artifacts/*.ipa'
    }
  }
}
```
