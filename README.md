Cliqz for iOS
===============

This branch (master)   [![Build Status](https://dev.azure.com/cliqzci/IOS/_apis/build/status/ghostery.browser-ios)](https://dev.azure.com/cliqzci/IOS/_build/latest?definitionId=1)
-----------

This branch is for mainline development.

This branch only works with Xcode 10.1 and supports iOS 11 and above.

This branch is written in Swift 4

Please make sure you aim your pull requests in the right direction.


Getting involved
----------------

We encourage you to participate in this open source project. We love Pull Requests, Bug Reports, ideas, (security) code reviews or any kind of positive contribution.


Building the code
-----------------

As of __April 2019__, this project requires the following versions of dependencies:
* MacOS Mojave
* Xcode 10.1
* Node.js 9
* Cocoapods 1.5.3

Make sure you have [homebrew](https://brew.sh/) installed:
```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
```

Then setup the project following these steps:
1. Install [Xcode 10.1](https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip)
  * Open the .xip archive
  * Move Xcode to `Application` folder
  * Setup Xcode and install CLI tools with the following commands:
```shell
sudo xcode-select -switch /Applications/Xcode.app
xcode-select --install
```
2. Install Node.js 9 (recommended: use [nvm](https://github.com/creationix/nvm)) + latest `npm` (this assumes you are using bash as your shell, if not, replace `bash` by your shell in the following commands):
```shell
brew install curl
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
source ~/.bashrc
nvm install 9
npm install -g npm@6.7.0
```
3. Install Carthage
 ```shell
brew install carthage
```
4. Install Ruby `bundler`:
```sh
sudo gem install bundler
bundle install
```
5. Install [cocoadpods](https://cocoapods.org/) version **1.5.3**
```shell
sudo gem install cocoapods -v 1.5.3
```
6. Fork the repository https://github.com/ghostery/browser-ios from GitHub UI
7. Clone the forked repository + add upstream remote:
```shell
git clone https://github.com/YOUR_USERNAME/ghostery-ios
cd ghostery-ios
git remote add upstream https://github.com/ghostery/browser-ios
git fetch upstream
git checkout upstream/master
git checkout -b my-working-branch
```
8. Pull in the project dependencies:
```shell
sh ./bootstrap.sh
npm ci
npm run bundle-lumen
# Or for Ghostery: npm run bundle-ghostery
rm -rf Pods
bundle exec pod install
npm run postinstall
```
9. Open `Client.xcworkspace` in Xcode.
10. Build the `Fennec` scheme in Xcode.

Note: When you run `bundle install`, you might get following error `An error occurred while installing unf_ext (0.0.7.5), and Bundler cannot continue.`. Above error happens with ruby 2.5.1. Just make sure to use 2.5.3 ruby version `rvm use 2.5.3` and problem will be fixed. 

## Building User Scripts

User Scripts (JavaScript injected into the `WKWebView`) are compiled, concatenated and minified using [webpack](https://webpack.js.org/). User Scripts to be aggregated are placed in the following directories:

```
/Client
|-- /Frontend
    |-- /UserContent
        |-- /UserScripts
            |-- /AllFrames
            |   |-- /AtDocumentEnd
            |   |-- /AtDocumentStart
            |-- /MainFrame
                |-- /AtDocumentEnd
                |-- /AtDocumentStart
```

This reduces the total possible number of User Scripts down to four. The compiled output from concatenating and minifying the User Scripts placed in these folders resides in `/Client/Assets` and are named accordingly:

* `AllFramesAtDocumentEnd.js`
* `AllFramesAtDocumentStart.js`
* `MainFrameAtDocumentEnd.js`
* `MainFrameAtDocumentStart.js`

To simplify the build process, these compiled files are checked-in to this repository. When adding or editing User Scripts, these files can be re-compiled with `webpack` manually. This requires Node.js to be installed and all required `npm` packages can be installed by running `npm install` in the root directory of the project. User Scripts can be compiled by running the following `npm` command in the root directory of the project:

```
npm run build
```

## Contributor guidelines

### Swift style
* Swift code should generally follow the conventions listed at https://github.com/raywenderlich/swift-style-guide.
  * Exception: we use 4-space indentation instead of 2.

### Whitespace
* New code should not contain any trailing whitespace.
* We recommend enabling both the "Automatically trim trailing whitespace" and "Including whitespace-only lines" preferences in Xcode (under Text Editing).
* <code>git rebase --whitespace=fix</code> can also be used to remove whitespace from your commits before issuing a pull request.

### Commits
* Each commit should have a single clear purpose. If a commit contains multiple unrelated changes, those changes should be split into separate commits.
* If a commit requires another commit to build properly, those commits should be squashed.
* Follow-up commits for any review comments should be squashed. Do not include "Fixed PR comments", merge commits, or other "temporary" commits in pull requests.
