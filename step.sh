#!/bin/bash
set -ex

echo "Build XCFramework for project: \n${project_path_input}\n${scheme}"

SCHEME_NAME=${scheme}
FRAMEWORK_NAME=${product_name}

SIMULATOR_ARCHIVE_PATH="${BUILD_DIR}/${CONFIGURATION}/${FRAMEWORK_NAME}-iphonesimulator.xcarchive"
DEVICE_ARCHIVE_PATH="${BUILD_DIR}/${CONFIGURATION}/${FRAMEWORK_NAME}-iphoneos.xcarchive"
OUTPUT_DIR="./xcframework/"

# Clean up old output directory
rm -rf "${OUTPUT_DIR}"

# Simulator xcarchive
xcodebuild archive \
  -project ${project_path_input} \
  -scheme ${SCHEME_NAME} \
  -archivePath ${SIMULATOR_ARCHIVE_PATH} \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Device xcarchive
xcodebuild archive \
  -project ${project_path_input} \
  -scheme ${SCHEME_NAME} \
  -archivePath ${DEVICE_ARCHIVE_PATH} \
  -sdk iphoneos \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create xcframweork
xcodebuild -create-xcframework \
  -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
  -framework ${DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
  -output ${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
envman add --key XCFRAMEWORK_PATH --value "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
