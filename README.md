# cocoa-i18n

## Usage

```
./CocoaLoco generate ~/Resources/LocalizableStrings.json ~/Resources/Output --objc --public --prefix "Base" --bundleName "hudlCapture"
```

1. The first param is the `inputURL` of the json file to process.
1. The second param is the `outputURL`, a directory where the output files should go.
1. `--objc` is optional, and will generate Objective-C compatibility
1. `--public` is optional, and will make the code `public`.
1. `--prefix` will prefix all the files, as well as the files struct / enum names with the provided prefix.
1. `--bundleName`, if you have a static extension on `Bundle` that provides a bundle, use it's name here. Providing `hudlCapture` will result in the code `Bundle.hudlCapture` as the internal bundle for loading the strings.

## Setup

To generate the xcodeproj file, use

```
swift package generate-xcodeproj
```

Then you can open `CocoaLoco.xcodeproj`. Tests won't be passing yet though, because SPM doesn't support resources. You will need to follow the below steps to get your resources added. It doesn't take long.

1. First you will need to create a new build phase within the tests target to copy our resources.
<img src="../master/docs/img/create_resources_phase.png" height="50%" width="50%">

2. Next, you'll need to add these files to our project.
<img src="../master/docs/img/add_files_to_project.png" height="50%" width="50%">

3. Finally, select the resources directory and make sure you add them to the correct group.
<img src="../master/docs/img/choose_files_and_target.png" height="50%" width="50%">

Tests should be passing now!

## Creating A Release

```
swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.14"
```

It will build to `.build/x86_64-apple-macosx/release/CocoaLoco`. That's your binary!

Eventually this should be distributed through SPM or CocoaPods, but for now we're just floating binaries.
