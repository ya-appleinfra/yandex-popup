#!/bin/bash


#####################
## INPUT VARIABLES ##
#####################

# Those are crucial for bulding this app. If left blank, values will be asked interactively
DEVELOPMENT_TEAM=""
PROVISIONING_PROFILE_PATH=""
PROVISIONING_PROFILE_SPECIFIER=""
PRODUCT_BUNDLE_IDENTIFIER=""
PRODUCT_NAME=""
BUILD_INSTALL_PACKAGE=""
SIGN_INSTALL_PACKAGE=""
INSTALL_PATH=""
SIGNING_IDENTITY=""

#####################
## OTHER VARIABLES ##
#####################

# Usually there is no need to change anything here
CUR_USER="$(/bin/ls -l /dev/console | awk '{print $3}')"
POVISIONING_PROFILES_FOLDER="/Users/${CUR_USER}/Library/MobileDevice/Provisioning Profiles"
SCRIPT_PATH=$(realpath "${0}")
SCRIPT_FOLDER=$(dirname "${scriptPath}")
CONFIG_PATH="${SCRIPT_FOLDER}/Release.xcconfig"

#####################
##    FUNCTIONS    ##
#####################

function get_provision_specifier() {
    local path=$1
    uuid=$(/usr/bin/security cms -D -i $path | xmllint --xpath "//key[text()='UUID']/following-sibling::string/text()" -)
    echo "$uuid"
}

function update_build_config() {
    sed -i '' "s/^DEVELOPMENT_TEAM = .*/DEVELOPMENT_TEAM = ${DEVELOPMENT_TEAM}/" "${CONFIG_PATH}"
    sed -i '' "s/^PROVISIONING_PROFILE_SPECIFIER = .*/PROVISIONING_PROFILE_SPECIFIER = ${PROVISIONING_PROFILE_SPECIFIER}/" "${CONFIG_PATH}"
    sed -i '' "s/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = ${PRODUCT_BUNDLE_IDENTIFIER}/" "${CONFIG_PATH}"
    sed -i '' "s/^PRODUCT_NAME = .*/PRODUCT_NAME = ${PRODUCT_NAME}/" "${CONFIG_PATH}"
    sed -i '' "s/^WRAPPER_NAME = .*/WRAPPER_NAME = ${PRODUCT_NAME}\.app/" "${CONFIG_PATH}"
    sed -i '' "s/^BUNDLE_DISPLAY_NAME = .*/BUNDLE_DISPLAY_NAME = ${PRODUCT_NAME}/" "${CONFIG_PATH}"
    sed -i '' "s/^EXECUTABLE_NAME = .*/EXECUTABLE_NAME = ${PRODUCT_NAME}/" "${CONFIG_PATH}"
}

function clean_build_config() {
    sed -i '' "s/^DEVELOPMENT_TEAM = .*/DEVELOPMENT_TEAM = /" "${CONFIG_PATH}"
    sed -i '' "s/^PROVISIONING_PROFILE_SPECIFIER = .*/PROVISIONING_PROFILE_SPECIFIER = /" "${CONFIG_PATH}"
    sed -i '' "s/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = /" "${CONFIG_PATH}"
    sed -i '' "s/^PRODUCT_NAME = .*/PRODUCT_NAME = /" "${CONFIG_PATH}"
    sed -i '' "s/^WRAPPER_NAME = .*/WRAPPER_NAME = /" "${CONFIG_PATH}"
    sed -i '' "s/^BUNDLE_DISPLAY_NAME = .*/BUNDLE_DISPLAY_NAME = /" "${CONFIG_PATH}"
    sed -i '' "s/^EXECUTABLE_NAME = .*/EXECUTABLE_NAME = /" "${CONFIG_PATH}"
}

#####################
##  PROCESS START  ##
#####################

# Processing input vars

if [ -z "${DEVELOPMENT_TEAM}" ]; then
    echo "Enter your development team ID:"
    read -r DEVELOPMENT_TEAM
    if [ -z "${DEVELOPMENT_TEAM}" ]; then
        echo "Development team ID cannot be empty. Exiting"
        exit 1
    fi
fi

if [ -z "${PROVISIONING_PROFILE_PATH}" ] && [ -z "${PROVISIONING_PROFILE_SPECIFIER}" ]; then
    echo "Enter path to provisioning profile or provisioning profile UUID if it is already installed:"
    read -r PROVISION
    if [ -z "${PROVISION}" ]; then
        echo "No provisioning profile. Exiting"
        exit 1
    fi
fi

# Checking provisioning input
if [ -n "$PROVISION" ]; then
    if [ -f "$PROVISION" ]; then
        PROVISIONING_PROFILE_PATH="${PROVISION}"
        PROVISIONING_PROFILE_SPECIFIER="$(get_provision_specifier ${PROVISIONING_PROFILE_PATH})"
        cp "${PROVISIONING_PROFILE_PATH}" "${POVISIONING_PROFILES_FOLDER}/${PROVISIONING_PROFILE_SPECIFIER}.provisionprofile"
    else
        # Asuming that we got profile UUID
        if [ -f "${POVISIONING_PROFILES_FOLDER}/${PROVISION}.provisionprofile" ]; then
            PROVISIONING_PROFILE_SPECIFIER="${PROVISION}"
        else
            echo "${POVISIONING_PROFILES_FOLDER}/${PROVISION}.provisionprofile not found. Exiting"
            exit 1
        fi
    fi
fi

if [ -z "${PROVISIONING_PROFILE_SPECIFIER}" ]; then
    if [ -f "${PROVISIONING_PROFILE_PATH}" ]; then
        PROVISIONING_PROFILE_SPECIFIER="$(get_provision_specifier ${PROVISIONING_PROFILE_PATH})"
        cp "${PROVISIONING_PROFILE_PATH}" "${POVISIONING_PROFILES_FOLDER}/${PROVISIONING_PROFILE_SPECIFIER}.provisionprofile"
    else
        echo "Unable to find provisioning profile. Exiting"
        exit 1
    fi
fi

# Checking bundleID
if [ -z "${PRODUCT_BUNDLE_IDENTIFIER}" ]; then
    echo "Enter bundle identifier for application (default: ru.yandex.yandex-popup):"
    read -r BUNDLE
    if [ -z "${BUNDLE}" ]; then
        PRODUCT_BUNDLE_IDENTIFIER="ru.yandex.yandex-popup"
    else
        PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE}"
    fi
fi

# Checking App Name
if [ -z "${PRODUCT_NAME}" ]; then
    echo "Enter application name (default: Yandex Popup):"
    read -r NAME
    if [ -z "${NAME}" ]; then
        PRODUCT_NAME="Yandex Popup"
    else
        PRODUCT_NAME="${NAME}"
    fi
fi

# Checking if install package is needed
if [ -z "${BUILD_INSTALL_PACKAGE}" ]; then
    echo "Do you wish to build install package for this app? (Y/n)"
    read -r BUILD
    if [ -z "${BUILD}" ]; then
        BUILD_INSTALL_PACKAGE=1
    else
        BUILD_INSTALL_PACKAGE="$(echo ${BUILD} | grep -Eq  '^(Y|y)$' > /dev/null && echo 1 || echo 0)"
    fi
fi

# Checking if installer package should be signed
if [ "${BUILD_INSTALL_PACKAGE}" -eq 1 ] && [ -z "${SIGN_INSTALL_PACKAGE}" ]; then
    echo "Do you wish to sign the installer package? (Y/n)"
    read -r SIGN
    if [ -z "${SIGN}" ]; then
        SIGN_INSTALL_PACKAGE=1
    else
        SIGN_INSTALL_PACKAGE="$(echo ${BUILD} | grep -Eq  '^(Y|y)$' > /dev/null && echo 1 || echo 0)"
    fi
fi

# Checking install directory
if [ "${BUILD_INSTALL_PACKAGE}" -eq 1 ] && [ -z "${INSTALL_PATH}" ]; then
    echo "Enter path, where the app should be installed (default: /Library/Application Support/${PRODUCT_NAME}/)"
    read -r INPUT_PATH
    if [ -z "${INPUT_PATH}" ]; then
        INSTALL_PATH="/Library/Application Support/${PRODUCT_NAME}"
    else
        INSTALL_PATH="${INPUT_PATH}"
    fi
fi

# Checking signing identity for installer package
if [ "${BUILD_INSTALL_PACKAGE}" -eq 1 ] && [ "${SIGN_INSTALL_PACKAGE}" -eq 1 ] && [ -z "${SIGNING_IDENTITY}" ]; then
    echo "Specify signing identity for the installer package (Developer ID Installer)"
    read -r SIGN_ID
    if [ -z "${SIGN_ID}" ]; then
        echo "Signing identity is not set. The installer package will not be signed"
        SIGN_INSTALL_PACKAGE=0
    else
        SIGNING_IDENTITY="${SIGN_ID}"
    fi
fi

update_build_config
xcodebuild clean build

if [ "${BUILD_INSTALL_PACKAGE}" == 1 ]; then
    if [ "${SIGN_INSTALL_PACKAGE}" == 1 ]; then
        productbuild --sign "${SIGNING_IDENTITY}" --component "./build/Release/${PRODUCT_NAME}.app"  "${INSTALL_PATH}" "${SCRIPT_FOLDER}/${PRODUCT_NAME}.pkg"
    else
        productbuild --component "./build/Release/${PRODUCT_NAME}.app"  "${INSTALL_PATH}" "${SCRIPT_FOLDER}/${PRODUCT_NAME}.pkg"
    fi
fi

# Cleanup
clean_build_config
