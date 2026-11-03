from pathlib import Path
import sys


gradle_file = Path(sys.argv[1])
contents = gradle_file.read_text(encoding="utf-8")
if "safety-observation-release-signing" in contents:
    raise SystemExit("Release signing is already configured")

contents += """

// safety-observation-release-signing
android {
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("RUNNER_TEMP") + "/safety-observation-upload.jks")
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
"""
gradle_file.write_text(contents, encoding="utf-8")
