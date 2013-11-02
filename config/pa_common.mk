# Set version
PA_VERSION_MAJOR = 4
PA_VERSION_MINOR = 0
PA_VERSION_MAINTENANCE = 0
PA_PREF_REVISION = 1

# Set audio
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=Themos.ogg \
    ro.config.notification_sound=Proxima.ogg \
    ro.config.alarm_alert=Cesium.ogg

# init.d support
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/common/bin/sysinit:system/bin/sysinit \
    vendor/pa/prebuilt/common/etc/init.pa.rc:root/init.pa.rc

# userinit support
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/pa/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/pa/prebuilt/common/bin/50-backupScript.sh:system/addon.d/50-backupScript.sh

# Gesture enabled JNI
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/common/lib/libjni_latinime.so:system/lib/libjni_latinime.so

# Bring in all video files
$(call inherit-product, frameworks/base/data/videos/VideoPackage2.mk)

# Exclude prebuilt paprefs from builds if the flag is set
ifneq ($(PREFS_FROM_SOURCE),true)
    PRODUCT_COPY_FILES += \
        vendor/pa/prebuilt/common/apk/ParanoidPreferences.apk:system/app/ParanoidPreferences.apk
else
    # Build paprefs from sources
    PRODUCT_PACKAGES += \
        ParanoidPreferences
endif

# ParanoidOTA
ifneq ($(NO_OTA_BUILD),true)
    PRODUCT_PACKAGES += \
        ParanoidOTA
endif

ifneq ($(PARANOID_BOOTANIMATION_NAME),)
    PRODUCT_COPY_FILES += \
        vendor/pa/prebuilt/common/bootanimation/$(PARANOID_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
else
    PRODUCT_COPY_FILES += \
        vendor/pa/prebuilt/common/bootanimation/XHDPI.zip:system/media/bootanimation.zip
endif

# Embed superuser into settings
SUPERUSER_EMBEDDED := true

# Enable root for adb+apps
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=3

# Superuser
PRODUCT_PACKAGES += \
    su

# device common prebuilts
ifneq ($(DEVICE_COMMON),)
    -include vendor/pa/prebuilt/$(DEVICE_COMMON)/prebuilt.mk
endif

# device specific prebuilts
-include vendor/pa/prebuilt/$(TARGET_PRODUCT)/prebuilt.mk

BOARD := $(subst pa_,,$(TARGET_PRODUCT))

# ParanoidAndroid Overlays
PRODUCT_PACKAGE_OVERLAYS += vendor/pa/overlay/common
PRODUCT_PACKAGE_OVERLAYS += vendor/pa/overlay/dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/pa/overlay/$(TARGET_PRODUCT)

# Allow device family to add overlays and use a same prop.conf
ifneq ($(OVERLAY_TARGET),)
    PRODUCT_PACKAGE_OVERLAYS += vendor/pa/overlay/$(OVERLAY_TARGET)
    PA_CONF_SOURCE := $(OVERLAY_TARGET)
else
    PA_CONF_SOURCE := $(TARGET_PRODUCT)
endif

PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/$(PA_CONF_SOURCE).conf:system/etc/paranoid/properties.conf \
    vendor/pa/prebuilt/$(PA_CONF_SOURCE).conf:system/etc/paranoid/backup.conf

ifneq ($(PRODUCT_IS_CDMA),)
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/common/etc/apns-conf-cdma.xml:system/etc/apns-conf.xml
else
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

# SIM Toolkit
PRODUCT_PACKAGES += \
    Stk \
    CellBroadcastReceiver
endif

# Copy ParanoidPreferences overlays
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/preferences/images/phablet.png:system/etc/paranoid/preferences/images/phablet.png \
    vendor/pa/prebuilt/preferences/images/phone.png:system/etc/paranoid/preferences/images/phone.png \
    vendor/pa/prebuilt/preferences/images/tablet.png:system/etc/paranoid/preferences/images/tablet.png \
    vendor/pa/prebuilt/preferences/images/undefined.png:system/etc/paranoid/preferences/images/undefined.png

PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/preferences/$(PA_CONF_SOURCE)/0_colors.xml:system/etc/paranoid/preferences/0_colors.xml \
    vendor/pa/prebuilt/preferences/$(PA_CONF_SOURCE)/pref_1.xml:system/etc/paranoid/preferences/pref_1.xml \
    vendor/pa/prebuilt/preferences/$(PA_CONF_SOURCE)/pref_2.xml:system/etc/paranoid/preferences/pref_2.xml \
    vendor/pa/prebuilt/preferences/$(PA_CONF_SOURCE)/pref_3.xml:system/etc/paranoid/preferences/pref_3.xml \
    vendor/pa/prebuilt/preferences/$(PA_CONF_SOURCE)/pref_4.xml:system/etc/paranoid/preferences/pref_4.xml

ifneq ($(PA_CONF_SOURCE),pa_tvdpi)
PRODUCT_COPY_FILES += \
    vendor/pa/prebuilt/preferences/$(PA_CONF_SOURCE)/pref_5.xml:system/etc/paranoid/preferences/pref_5.xml
endif

# Set vendor version and target name
VERSION := $(PA_VERSION_MAJOR).$(PA_VERSION_MINOR)$(PA_VERSION_MAINTENANCE)
ifeq ($(DEVELOPER_VERSION),true)
    PA_VERSION := dev_$(BOARD)-$(VERSION)-$(shell date -u +%Y%m%d)
else
    PA_VERSION := $(TARGET_PRODUCT)-$(VERSION)-$(shell date -u +%Y%m%d)
endif

VENDOR_OTA_PACKAGE_TARGET := $(PA_VERSION)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.modversion=$(PA_VERSION) \
    ro.pa.family=$(PA_CONF_SOURCE) \
    ro.pa.version=$(VERSION) \
    ro.papref.revision=$(PA_PREF_REVISION) \
    ro.pa=true
