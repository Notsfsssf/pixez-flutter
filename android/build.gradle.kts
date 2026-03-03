/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 强制覆盖所有子项目(插件)的配置
subprojects {
    // 定义一个修改函数，避免重复代码
    fun com.android.build.gradle.LibraryExtension.forceUpgrade() {
        compileSdk = 36

        // 很多老旧插件没有 namespace，强制升级 SDK 后必须补上，否则会报错
        if (namespace == null) {
            namespace = project.group.toString()
        }
    }

    // 1. 针对尚未配置的项目，注册 afterEvaluate 钩子，确保在插件配置完成后执行覆盖
    if (!project.state.executed) {
        project.afterEvaluate {
            if (project.plugins.hasPlugin("com.android.library")) {
                project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                    forceUpgrade()
                }
            }
        }
    }
    // 2. 针对已经配置完成的项目，直接执行覆盖（防止报 already evaluated 错误）
    else {
        if (project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                forceUpgrade()
            }
        }
    }
}