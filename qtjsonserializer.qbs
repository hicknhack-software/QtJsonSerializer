import qbs

Project {
    name: "QtJsonSerializer"

    references: [
        "src",
    ]

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
