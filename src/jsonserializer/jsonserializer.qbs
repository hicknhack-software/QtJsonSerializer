import qbs
import qbs.TextFile

DynamicLibrary {
    id: root
    targetName: "QtJsonSerializer"

    Depends { name: "Qt.core" }
    Depends { name: "cpp" }
    cpp.cxxLanguageVersion: "c++14"
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
        "typeconverters/qjsonstdtupleconverter.cpp",
        "typeconverters/qjsonstdtupleconverter_p.h",
        "typeconverters/qjsonversionnumberconverter.cpp",
        "typeconverters/qjsonversionnumberconverter_p.h",
    ]

    // create type registrations from template
    FileTagger {
        patterns: "*.template"
        fileTags: ["template"]
    }
    property varList types: {
        var r = [];

        var ALL_TYPES = [
            "bool",
            "int",
            "uint",
            "qlonglong",
            "qulonglong",
            "double",
            "long",
            "short",
            "char",
            "signed char",
            "ulong",
            "ushort",
            "uchar",
            "float",
            "QObject*",
            "QChar",
            "QString",
            "QDate",
            "QTime",
            "QDateTime",
            "QUrl",
            "QUuid",
            "QJsonValue",
            "QJsonObject",
            "QJsonArray",
            "QVersionNumber",
            "QLocale",
            "QRegularExpression",
        ];
        var LIST_TYPES = [
            "QSize",
            "QPoint",
            "QLine",
            "QRect",
        ];
        var MAP_TYPES = ["QByteArray"];
        var SET_TYPES = ["QByteArray"];

        ALL_TYPES.forEach(function(t) {
            r.push({
                type: t,
                convertMethod: "registerAllConverters",
                convertOp: "list, map and set"
            });
        });
        LIST_TYPES.forEach(function(t) {
           r.push({
               type: t,
               convertMethod: "registerListConverters",
               convertOp: "map"
           });
        });
        MAP_TYPES.forEach(function(t) {
            r.push({
                type: t,
                convertMethod: "registerMapConverters",
                convertOp: "list"
            });
        });
        SET_TYPES.forEach(function(t) {
            r.push({
                type: t,
                convertMethod: "registerSetConverters",
                convertOp: "set"
            });
        });
        return r;
    }
    Rule {
        inputs: "template"
        outputFileTags: ["cpp"]

        outputArtifacts: {
            var r = [];
            r.push({
                filePath: ".reggen/qjsonconverterreg_all.cpp",
                fileTags: ["cpp"],
            });
            product.types.forEach(function(to, i) {
                r.push({
                    filePath: ".reggen/qjsonconverterreg_"+ i +".cpp",
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
                var templateFile = new TextFile(input.filePath);
                var templateText = templateFile.readAll();
                templateFile.close();
                var reTypeIndex = /\%\{typeindex\}/g;
                var reConvertMethod = /\%\{convertMethod\}/g;
                var reType = /\%\{type\}/g;
                var reConvertOp = /\%\{convertOp\}/g;

                outputs.cpp.forEach(function(out, i) {
                    var text;
                    if (i == 0) {
                        text = "#include \"qtjsonserializer_global.h\"\n\n";
                        text += "namespace _qjsonserializer_helpertypes {\n";
                        text += "namespace converter_hooks {\n";
                        typeList.forEach(function(tl, ti) {
                            text += "void register_"+ ti +"_converters();\n";
                        });
                        text += "} // namespace converter_hooks\n";
                        text += "} // namespace _qjsonserializer_helpertypes\n\n";
                        text += "void qtJsonSerializerRegisterTypes() {\n";
                        text += "   static bool wasCalled = false;\n";
                        text += "   if (wasCalled) return;\n";
                        text += "   wasCalled = true;\n";
                        typeList.forEach(function(tl, ti) {
                            text += "   _qjsonserializer_helpertypes::converter_hooks::register_"+ ti +"_converters();\n";
                        });
                        text += "}";
                    }
                    else {
                        var ti = i-1;
                        var tl = typeList[ti];
                        text = templateText;
                        text = text.replace(reTypeIndex, ti);
                        text = text.replace(reConvertMethod, tl.convertMethod);
                        text = text.replace(reType, tl.type);
                        text = text.replace(reConvertOp, tl.convertOp);
                    }
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
            cmd.description = "generating converters registrations";
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
        cpp.cxxLanguageVersion: "c++14"
        cpp.includePaths: [
            ".",
            product.buildDirectory + "/include"
        ]
    }
}
