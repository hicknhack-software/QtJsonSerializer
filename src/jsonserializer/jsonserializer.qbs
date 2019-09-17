import qbs
import qbs.TextFile

Product {
    id: root

    property bool isAndroid: qbs.targetOS.contains("android")
    property bool isMacOS: qbs.targetOS.contains("macos")
    property bool isWindows: qbs.targetOS.contains("windows")

    targetName: "QtJsonSerializer"

    Depends { name: "Qt.core" }
    Depends { name: "cpp" }

    type: {
        if (isAndroid) {
            return "staticlibrary"
        }
        else if (isMacOS) {
            return "staticlibrary"
        }
        else if (isWindows) {
            return "dynamiclibrary"
        }
    }

    Properties {
        condition: qbs.targetOS.contains("android")
        type: ["staticlibrary"]
    }

    cpp.cxxLanguageVersion: "c++17"
    cpp.includePaths: [
        ".",
        product.buildDirectory + "/include"
    ]
    cpp.defines: [
        "QT_BUILD_JSONSERIALIZER_LIB",
    ]

    files: [
        "qjsonconverterreg.cpp.template",
        "qjsonexceptioncontext.cpp",
        "qjsonexceptioncontext_p.h",
        "qjsonserializer.cpp",
        "qjsonserializer.h",
        "qjsonserializer_helpertypes.h",
        "qjsonserializer_p.h",
        "qjsonserializerexception.cpp",
        "qjsonserializerexception.h",
        "qjsonserializerexception_p.h",
        "qjsontypeconverter.cpp",
        "qjsontypeconverter.h",
        "qtjsonserializer_global.h",
        "typeconverters/qjsonbytearrayconverter.cpp",
        "typeconverters/qjsonbytearrayconverter_p.h",
        "typeconverters/qjsonchronodurationconverter.cpp",
        "typeconverters/qjsonchronodurationconverter_p.h",
        "typeconverters/qjsongadgetconverter.cpp",
        "typeconverters/qjsongadgetconverter_p.h",
        "typeconverters/qjsongeomconverter.cpp",
        "typeconverters/qjsongeomconverter_p.h",
        "typeconverters/qjsonjsonconverter.cpp",
        "typeconverters/qjsonjsonconverter_p.h",
        "typeconverters/qjsonlistconverter.cpp",
        "typeconverters/qjsonlistconverter_p.h",
        "typeconverters/qjsonlocaleconverter.cpp",
        "typeconverters/qjsonlocaleconverter_p.h",
        "typeconverters/qjsonmapconverter.cpp",
        "typeconverters/qjsonmapconverter_p.h",
        "typeconverters/qjsonmultimapconverter.cpp",
        "typeconverters/qjsonmultimapconverter_p.h",
        "typeconverters/qjsonobjectconverter.cpp",
        "typeconverters/qjsonobjectconverter_p.h",
        "typeconverters/qjsonpairconverter.cpp",
        "typeconverters/qjsonpairconverter_p.h",
        "typeconverters/qjsonregularexpressionconverter.cpp",
        "typeconverters/qjsonregularexpressionconverter_p.h",
        "typeconverters/qjsonstdoptionalconverter.cpp",
        "typeconverters/qjsonstdoptionalconverter_p.h",
        "typeconverters/qjsonstdtupleconverter.cpp",
        "typeconverters/qjsonstdtupleconverter_p.h",
        "typeconverters/qjsonstdvariantconverter.cpp",
        "typeconverters/qjsonstdvariantconverter_p.h",
        "typeconverters/qjsonversionnumberconverter.cpp",
        "typeconverters/qjsonversionnumberconverter_p.h",
    ]

    // create type registrations from template
    FileTagger {
        patterns: "*.template"
        fileTags: ["template"]
    }
    property varList types: [
        {className: "bool", modes: ["Basic"]},
        {className: "int", modes: ["Basic"]},
        {className: "uint", modes: ["Basic"]},
        {className: "qlonglong", modes: ["Basic"]},
        {className: "qulonglong", modes: ["Basic"]},
        {className: "double", modes: ["Basic"]},
        {className: "long", modes: ["Basic"]},
        {className: "short", modes: ["Basic"]},
        {className: "char", modes: ["Basic"]},
        {className: "signed char", modes: ["Basic"]},
        {className: "ulong", modes: ["Basic"]},
        {className: "ushort", modes: ["Basic"]},
        {className: "uchar", modes: ["Basic"]},
        {className: "float", modes: ["Basic"]},
        {className: "QObject*", modes: ["Basic"]},
        {className: "QChar", modes: ["Basic"]},
        {className: "QString", modes: ["Basic"]},
        {className: "QDate", modes: ["Basic"]},
        {className: "QTime", modes: ["Basic"]},
        {className: "QDateTime", modes: ["Basic"]},
        {className: "QUrl", modes: ["Basic"]},
        {className: "QUuid", modes: ["Basic"]},
        {className: "QJsonValue", modes: ["Basic"]},
        {className: "QJsonObject", modes: ["Basic"]},
        {className: "QJsonArray", modes: ["Basic"]},
        {className: "QVersionNumber", modes: ["Basic"]},
        {className: "QLocale", modes: ["Basic"]},
        {className: "QRegularExpression", modes: ["Basic"]},
        {className: "QSize", modes: ["List"]},
        {className: "QPoint", modes: ["List"]},
        {className: "QLine", modes: ["List"]},
        {className: "QRect", modes: ["List"]},
        {className: "QByteArray", modes: ["Map", "Set"]}
    ]
    Rule {
        inputs: "template"
        outputFileTags: ["cpp"]

        outputArtifacts: {
            function myEscape(n) {
                return n.replace(/\W/g, '_');
            }
            var r = [];
            r.push({
                       filePath: ".reggen/qjsonconverterreg_all.cpp",
                       fileTags: ["cpp"],
                   });
            product.types.forEach(function(type) {
                r.push({
                           filePath: ".reggen/qjsonconverterreg_"+ myEscape(type.className) +".cpp",
                           fileTags: ["cpp"],
                       });
            });
            return r;
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "generating converters registrations";
            cmd.highlight = "codegen";
            cmd.typeList = product.types;
            cmd.sourceCode = function() {
                function myEscape(n) {
                    return n.replace(/\W/g, '_');
                }

                {
                    var out = outputs.cpp[0];
                    var text = "#include \"qtjsonserializer_global.h\"\n";
                    text += "\n";
                    text += "namespace _qjsonserializer_helpertypes::converter_hooks {\n";
                    text += "\n";
                    typeList.forEach(function(type) {
                        text += "void register_"+ myEscape(type.className) +"_converters();\n";
                    });
                    text += "}\n";
                    text += "\n";
                    text += "void qtJsonSerializerRegisterTypes() {\n";
                    text += "    static bool wasCalled = false;\n";
                    text += "    if (wasCalled)\n";
                    text += "        return;\n";
                    text += "    wasCalled = true;\n";
                    typeList.forEach(function(type) {
                        text += "   _qjsonserializer_helpertypes::converter_hooks::register_"+ myEscape(type.className) +"_converters();\n";
                    });
                    text += "}\n";
                    var outFile = new TextFile(out.filePath, TextFile.WriteOnly);
                    outFile.write(text);
                    outFile.close();
                }

                var i = 1;
                typeList.forEach(function(type) {
                    var class_name = type.className;
                    var modes = type.modes;
                    var out = outputs.cpp[i];
                    i++;
                    var text = '#include "qtjsonserializer_global.h"\n';
                    text += '#include "qjsonserializer.h"\n';
                    text += "#include <QtCore/QtCore>\n";
                    text += "\n";
                    text += "#define QT_JSON_SERIALIZER_NAMED(T) #T\n";
                    text += "\n";
                    text += "namespace _qjsonserializer_helpertypes::converter_hooks {\n";
                    text += "\n";

                    text += "void register_"+myEscape(class_name)+"_converters() {\n";
                    text += "    bool ok;\n";
                    modes.forEach(function(mode) {
                        var fn = "register"+mode+"Converters";
                        text += "    ok = QJsonSerializer::"+fn+"<"+class_name+">();\n";
                        text += '    Q_ASSERT_X(ok, Q_FUNC_INFO, "Failed to register '+mode+' converters for type " QT_JSON_SERIALIZER_NAMED('+class_name+'));\n';
                    });
                    text += "}\n";
                    text += "\n";
                    text += "} // namespace _qjsonserializer_helpertypes::converter_hooks\n";

                    var outFile = new TextFile(out.filePath, TextFile.WriteOnly);
                    outFile.write(text);
                    outFile.close();
                });
            };
            return [cmd];
        }
    }

    // create public headers that are required for includes
    FileTagger {
        patterns: "*.h"
        fileTags: ["public_header"]
    }
    Rule {
        inputs: ["public_header"]
        outputFileTags: ["hpp"]
        Artifact {
            filePath: "include/" + product.targetName + '/' + input.fileName
            fileTags: ["hpp"]
        }
        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "publishing header " + input.fileName;
            cmd.highlight = "codegen";
            cmd.input = input.filePath;
            cmd.output = output.filePath;
            cmd.sourceCode = function() {
                var outFile = new TextFile(output, TextFile.WriteOnly);
                outFile.write("#include \""+ input +"\"");
                outFile.close();
            };
            return [cmd];
        }
    }

    Export {
        Depends { name: "Qt.core" }
        Depends { name: "cpp" }
        cpp.cxxLanguageVersion: "c++17"
        cpp.includePaths: [
            ".",
            product.buildDirectory + "/include"
        ]
    }
}
