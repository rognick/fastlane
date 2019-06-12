Objective-C/Swift and Android Framework Deployment
================

A fastlane setup to deploy iOS and Android app.

## Installation
To install fastlane, simply use gem (related: [Should I use sudo?](http://stackoverflow.com/a/2119413)):

```
[sudo] gem install fastlane
```

## Gemfile
```
gem "fastlane"
gem "slather"
gem "fastlane-plugin-lizard"
gem 'cocoapods', '~> 1.5', '>= 1.5.3'
gem 'fastlane-plugin-appcenter', '~> 0.1.7'
gem 'fastlane-plugin-versioning_android'
```

## Git Ignore files
```
build/
reports/
sonar-reports/

# fastlane:
# It is recommended to not store the screenshots in the git repo. Instead, use fastlane to re-generate the
# screenshots whenever they are needed.
# For more information about the recommended setup visit:
# https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Gitignore.md
# fastlane specific

**/fastlane/report.xml

# deliver temporary files
**/fastlane/Preview.html

# snapshot generated screenshots
**/fastlane/screenshots

# scan temporary files
**/fastlane/test_output
**/fastlane/.env.localsonar
artifacts
```


## ENV params:
```
TEAMS_URL=""

DEPLOY_PLIST_PATH=TestFastlane/Info.plist

PROJ_SOURCES_PATH

PROJECT_NAME="TEST"

SCHEME="TestFastlane"

# API Token for App Center
APPCENTER_API_TOKEN=""

# Jira:
JIRA_URL="server_url/jira/browse/"
JIRA_ISSUE_KEY="(SF|PSD|PSD2)"
```
