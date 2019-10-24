import qbs

Project {
    id: src

    property bool install: false
    property string installDir

    SubProject {
        filePath: "jsonserializer/jsonserializer.qbs"
        Properties {
            install: src.install
            installDir: src.installDir
        }
    }
}
