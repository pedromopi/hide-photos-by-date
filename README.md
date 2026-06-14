# PhotoHider

App iOS (SwiftUI, iOS 16+) para ocultar fotos em massa usando a API oficial do Photos.

## Funcionalidade

1. Solicita permissao de acesso `readWrite` a biblioteca de fotos.
2. Conta fotos visiveis (`hidden == NO`).
3. Marca todas as fotos visiveis como ocultas (`isHidden = true`) em lotes.

## Build

1. Rode `xcodegen generate` dentro da pasta.
2. Abra `PhotoManager.xcodeproj` no Xcode.
