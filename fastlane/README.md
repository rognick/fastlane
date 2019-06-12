fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### upload_to_appcenter
```
fastlane upload_to_appcenter
```
Upload app to appcenter

----

## iOS
### ios clear_data
```
fastlane ios clear_data
```
Clear data and folders
### ios install_pods
```
fastlane ios install_pods
```
Install pod dependencies
### ios build_development
```
fastlane ios build_development
```
Prepares the framework for release

This lane should be run from your local machine, and will push a tag to the remote when finished.

 * **`allow_dirty_branch`**: Allows the git branch to be dirty before continuing. Defaults to false
### ios push_to_git_tags_and_commit
```
fastlane ios push_to_git_tags_and_commit
```


----

## Android
### android clear_data
```
fastlane android clear_data
```
Clear data and folders
### android build_development
```
fastlane android build_development
```
Prepares the framework for release

This lane should be run from your local machine, and will push a tag to the remote when finished.

 * **`allow_dirty_branch`**: Allows the git branch to be dirty before continuing. Defaults to false
### android push_to_git_tags_and_commit
```
fastlane android push_to_git_tags_and_commit
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
