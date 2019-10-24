import qbs

Project {
    id: qtjsonserializer

    property bool install: false
    property string installDir

    name: "QtJsonSerializer"

    SubProject {
        filePath: "src/src.qbs"
        Properties {
            install: qtjsonserializer.install
            installDir: qtjsonserializer.installDir
        }
    }

    AutotestRunner {}

    Product {
        name: "[Extra Files]"
        files: [
            ".travis.yml",
            "LICENSE",
            "README.md",
            "appveyor.yml",
        ]
    }
}
