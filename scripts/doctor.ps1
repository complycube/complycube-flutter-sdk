<#
    Simple environment doctor script for the ComplyCube Flutter sample (PowerShell version).

    This script checks that the Flutter toolchain, Java JDK, Gradle wrapper, Android Gradle Plugin (AGP),
    and Android SDK versions are correctly configured. It also verifies CocoaPods when run on macOS.
    To run this script: `powershell -ExecutionPolicy Bypass -File scripts/doctor.ps1`

    Note: This script is a best-effort port of `doctor.sh`. It uses PowerShell's cross-platform features,
    so it should work on Windows PowerShell 5.1 and PowerShell Core on macOS/Linux.
#>

param()

function Write-Heading {
    param($Title)
    Write-Host "`n$Title" -ForegroundColor Cyan -NoNewline
    Write-Host ""
}

function Write-Ok {
    param($Message)
    Write-Host "✔ $Message" -ForegroundColor Green
}

function Write-Warn {
    param($Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Err {
    param($Message)
    Write-Host "✖ $Message" -ForegroundColor Red
}

function Write-Fix {
    param(
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter()][string[]]$Commands
    )
    Write-Host "  Fix: $Title" -ForegroundColor DarkYellow
    if ($Commands) {
        foreach ($cmd in $Commands) {
            Write-Host "       $cmd" -ForegroundColor DarkYellow
        }
    }
}

function Check-Command {
    param($Cmd)
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) {
        Write-Ok "$Cmd is installed"
        return $true
    } else {
        Write-Err "$Cmd is not installed or not on PATH"
        return $false
    }
}

function Parse-JavaVersion {
    param($VersionString)
    # Extract major version from strings like "17.0.9" or "21.0.1"
    if ($VersionString -match '([0-9]+)\.([0-9]+)\.([0-9]+)') {
        return [int]$Matches[1]
    }
    return $null
}

function Normalize-Version {
    param([string]$Version)
    if (-not $Version) { return $null }
    # Ensure we always have 3 components so [Version] parsing is reliable
    if ($Version -match '^\d+\.\d+$') { return "$Version.0" }
    if ($Version -match '^\d+\.\d+\.\d+$') { return $Version }
    return $Version
}

function Get-MinAgpForCompileSdk {
    param([int]$CompileSdk)
    switch ($CompileSdk) {
        33 { return "7.2.0" }
        34 { return "8.1.1" }
        35 { return "8.6.0" }
        36 { return "8.9.1" }
        default { return $null }
    }
}

Write-Heading "Flutter Doctor Check"
if (Check-Command "flutter") {
    try {
        & flutter doctor -v
    } catch {
        Write-Warn "Failed to run 'flutter doctor'"
        Write-Fix "Try running Flutter diagnostics manually" @(
            "flutter --version",
            "flutter doctor -v"
        )
    }
} else {
    Write-Fix "Install Flutter and ensure it's on PATH" @(
        "Follow: https://docs.flutter.dev/get-started/install",
        "Then run: flutter --version",
        "Then run: flutter doctor -v"
    )
}

Write-Heading "Java / JDK"
if (Check-Command "java") {
    $javaOutput = (& java -version 2>&1)[0]
    $javaMajor = Parse-JavaVersion $javaOutput
    Write-Host "  Java version          : $javaOutput"
    if ($null -ne $javaMajor) {
        if ($javaMajor -ge 17 -and $javaMajor -le 21) {
            Write-Ok "Supported JDK version detected (>=17 <=21)"
        } else {
            Write-Warn "JDK $javaMajor detected. For modern Android toolchains we recommend JDK 17 or 21."
            Write-Fix "Install and use JDK 17" @(
                "Windows (winget): winget install Microsoft.OpenJDK.17",
                "Windows (Chocolatey): choco install temurin17",
                "macOS (Homebrew): brew install openjdk@17",
                "Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y openjdk-17-jdk",
                "Verify: java -version"
            )
        }
    }
} else {
    Write-Err "Java is not installed or not on PATH"
    Write-Fix "Install JDK 17 and ensure 'java' is on PATH" @(
        "Windows (winget): winget install Microsoft.OpenJDK.17",
        "Windows (Chocolatey): choco install temurin17",
        "macOS (Homebrew): brew install openjdk@17",
        "Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y openjdk-17-jdk",
        "Verify: java -version"
    )
}

if ($env:JAVA_HOME) {
    Write-Host "  JAVA_HOME             : $env:JAVA_HOME"
} else {
    Write-Warn "JAVA_HOME is not set; Flutter will fall back to Android Studio's embedded JDK if available."
    Write-Fix "Set JAVA_HOME (recommended)" @(
        "Windows (session): setx JAVA_HOME ""C:\Program Files\Java\jdk-17""",
        "macOS: export JAVA_HOME=""\$(/usr/libexec/java_home -v 17)""",
        "Then re-run: java -version"
    )
}

Write-Heading "Gradle Wrapper"
$wrapperFile = Join-Path -Path "android/gradle/wrapper" -ChildPath "gradle-wrapper.properties"
if (Test-Path $wrapperFile) {
    Write-Host "  Found                 : $wrapperFile"
    $distLine = Select-String -Path $wrapperFile -Pattern '^distributionUrl' | Select-Object -First 1
    if ($distLine) {
        if ($distLine.Line -match 'gradle-([0-9]+\.[0-9]+\.?[0-9]*)') {
            $gradleVer = $Matches[1]
            Write-Host "  Gradle version        : $gradleVer"
            $gradleMajor = ($gradleVer.Split('.')[0] -as [int])
            if ($gradleMajor -lt 8) {
                Write-Warn "Gradle $gradleVer detected. Consider upgrading to Gradle 8.x for modern AGP compatibility."
                Write-Fix "Upgrade Gradle Wrapper (choose a version compatible with your AGP)" @(
                    "cd android",
                    "./gradlew wrapper --gradle-version 8.13 --distribution-type all",
                    "cd .."
                )
            } else {
                Write-Ok "Gradle version is acceptable"
            }
        } else {
            Write-Warn "Could not parse Gradle version from distributionUrl"
        }
    }
} else {
    Write-Warn "Gradle wrapper file not found at $wrapperFile"
    Write-Fix "Ensure you're in the sample app root (android/ exists)" @(
        "From repo root, run: flutter pub get",
        "If android/ was deleted, regenerate platform folders with: flutter create ."
    )
}

Write-Heading "Android Gradle Plugin (AGP)"
$agpVersion = $null
$settingsGradle = "android/settings.gradle"
$rootBuild = "android/build.gradle"
if (Test-Path $settingsGradle) {
    $agpLine = Select-String -Path $settingsGradle -Pattern 'com\.android\.application"\s+version' | Select-Object -First 1
    if ($agpLine) {
        if ($agpLine.Line -match '"([0-9]+\.[0-9]+\.[0-9]+)"') {
            $agpVersion = $Matches[1]
        }
    }
}
if (-not $agpVersion -and (Test-Path $rootBuild)) {
    $agpLine = Select-String -Path $rootBuild -Pattern 'com\.android\.tools\.build:gradle' | Select-Object -First 1
    if ($agpLine) {
        if ($agpLine.Line -match '([0-9]+\.[0-9]+\.[0-9]+)') {
            $agpVersion = $Matches[1]
        }
    }
}
if ($agpVersion) {
    Write-Host "  AGP version           : $agpVersion"
    # Best-effort compatibility check against compileSdk if available
    $appBuildPath = "android/app/build.gradle"
    if (Test-Path $appBuildPath) {
        $cLine = Select-String -Path $appBuildPath -Pattern 'compileSdkVersion\s+([0-9]+)' | Select-Object -First 1
        if ($cLine -and ($cLine.Line -match 'compileSdkVersion\s+([0-9]+)')) {
            $cSdk = [int]$Matches[1]
            $minAgp = Get-MinAgpForCompileSdk $cSdk
            if ($minAgp) {
                $agpNorm = Normalize-Version $agpVersion
                $minNorm = Normalize-Version $minAgp
                try {
                    if ([Version]$agpNorm -lt [Version]$minNorm) {
                        Write-Warn "AGP $agpVersion may be too low for compileSdk $cSdk (suggested minimum: $minAgp)."
                        Write-Fix "Upgrade AGP in android/settings.gradle" @(
                            "Open: android/settings.gradle",
                            "Update plugins block: id ""com.android.application"" version ""$minAgp"" apply false",
                            "Then: flutter clean && flutter pub get && flutter run"
                        )
                        Write-Warn "If targeting Android API 36.1 previews, you may need AGP 8.13.x."
                    } else {
                        Write-Ok "AGP version looks compatible with compileSdk (best effort)"
                    }
                } catch {
                    Write-Warn "Could not compare AGP versions."
                }
            }
        }
    }
} else {
    Write-Warn "Could not detect Android Gradle Plugin version from settings.gradle or build.gradle"
    Write-Fix "Declare AGP in android/settings.gradle" @(
        "In the plugins block, add something like:",
        "  id ""com.android.application"" version ""8.6.0"" apply false",
        "Then re-run: flutter run"
    )
}

Write-Heading "Android SDK Versions"
$appBuild = "android/app/build.gradle"
if (Test-Path $appBuild) {
    $compileSdk = ($null)
    $targetSdk  = ($null)
    $minSdk     = ($null)
    $content = Get-Content $appBuild
    foreach ($line in $content) {
        if (-not $compileSdk -and $line -match 'compileSdkVersion\s+([0-9]+)') {
            $compileSdk = $Matches[1]
        }
        if (-not $targetSdk -and $line -match 'targetSdkVersion\s+([0-9]+)') {
            $targetSdk = $Matches[1]
        }
        if (-not $minSdk -and $line -match 'minSdkVersion\s+([0-9]+)') {
            $minSdk = $Matches[1]
        }
    }
    if ($compileSdk) { Write-Host "  compileSdkVersion     : $compileSdk" } else { Write-Warn "compileSdkVersion not found" }
    if ($targetSdk)  { Write-Host "  targetSdkVersion      : $targetSdk" }  else { Write-Warn "targetSdkVersion not found" }
    if ($minSdk)     { Write-Host "  minSdkVersion         : $minSdk" }     else { Write-Warn "minSdkVersion not found" }

    # Android SDK location + required platform check
    $androidSdk = $env:ANDROID_SDK_ROOT
    if (-not $androidSdk) { $androidSdk = $env:ANDROID_HOME }
    if ($androidSdk) {
        Write-Host "  Android SDK path       : $androidSdk"
        if ($compileSdk) {
            $platDir = Join-Path $androidSdk "platforms/android-$compileSdk"
            if (-not (Test-Path $platDir)) {
                Write-Warn "Android SDK platform android-$compileSdk not found under your SDK path."
                Write-Fix "Install the required Android platform" @(
                    "Android Studio: Settings/Preferences > Android SDK > install Android $compileSdk",
                    "Or CLI (if sdkmanager available): sdkmanager ""platforms;android-$compileSdk""",
                    "Then: flutter clean && flutter run"
                )
            } else {
                Write-Ok "Android SDK platform looks OK (best effort)"
            }
        }
    } else {
        Write-Warn "ANDROID_SDK_ROOT/ANDROID_HOME not set. Flutter may still work via Android Studio configuration, but explicit SDK path helps."
        Write-Fix "Ensure Android SDK is installed and configured" @(
            "Install Android Studio (recommended)",
            "Set ANDROID_SDK_ROOT (example): setx ANDROID_SDK_ROOT %USERPROFILE%\AppData\Local\Android\Sdk",
            "Then re-run: flutter doctor -v"
        )
    }
} else {
    Write-Warn "$appBuild not found. Cannot parse SDK versions."
    Write-Fix "Ensure you're in the sample app root (android/app/build.gradle exists)" @(
        "From repo root, run: flutter pub get",
        "If platform folders are missing, regenerate with: flutter create ."
    )
}

Write-Heading "iOS (macOS only)"
if ($IsMacOS) {
    if (Get-Command "pod" -ErrorAction SilentlyContinue) {
        $podVersion = pod --version
        Write-Host "  CocoaPods version     : $podVersion"
    } else {
        Write-Warn "CocoaPods (pod) is not installed. Run 'sudo gem install cocoapods' or use Homebrew."
        Write-Fix "Install CocoaPods" @(
            "macOS (RubyGems): sudo gem install cocoapods",
            "macOS (Homebrew): brew install cocoapods",
            "Then: cd ios; pod install; cd .."
        )
    }
}

Write-Heading "Summary"
Write-Host "If any of the items above are marked with a warning (⚠) or error (✖), please review the accompanying notes and adjust your setup accordingly."
Write-Host "This script is a helper and does not modify your system."
