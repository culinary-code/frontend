# Keep errorprone annotations
-keep class com.google.errorprone.annotations.** { *; }

# Keep javax annotations
-keep class javax.annotation.** { *; }

# Suppress warnings for missing javax annotations and modifier-related classes
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn javax.lang.model.element.Modifier
