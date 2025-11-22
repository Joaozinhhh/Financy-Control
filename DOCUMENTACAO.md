# Financy Control - Documentação do Projeto

## Visão Geral do Projeto

Aplicativo de gerenciamento de finanças pessoais desenvolvido em Flutter, seguindo uma arquitetura feature-first com padrão MVVM. Atualmente em desenvolvimento ativo com camada de dados mockada e funcionalidades de UI em evolução.

## Arquitetura e Padrões de Design

### Estrutura de Diretórios Feature-First

O projeto organiza o código por funcionalidades (features), não por camadas técnicas:

```text
lib/
├── features/
│   ├── transactions/
│   │   ├── transactions_view.dart
│   │   └── transactions_view_model.dart
│   ├── categories/
│   ├── statistics/
│   └── profile/
├── core/
│   ├── models/
│   ├── data/
│   └── extensions.dart
├── services/
└── repositories/
```

**Princípios:**

- Cada feature contém sua View, ViewModel e componentes UI relacionados
- View e ViewModel são arquivos pareados no mesmo diretório
- Não há pasta `presentation/` separada - mantemos simples

### Padrão MVVM com ChangeNotifier

#### ViewModels

- Estendem `ChangeNotifier`
- Utilizam helper `rebuild()` de `core/extensions.dart` ao invés de chamar `notifyListeners()` diretamente
- `rebuild()` registra logs quando não há listeners (previne bugs silenciosos)

**Padrão de implementação:**

```dart
class TransactionsViewModel extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  
  List<TransactionModel> get transactions => _transactions;
  
  set transactions(List<TransactionModel> value) {
    _transactions = value;
    rebuild(); // Ao invés de notifyListeners()
  }
}
```

#### Views

- `StatefulWidget` que escuta mudanças do ViewModel
- Sempre adicionar listener em `initState()` e remover em `dispose()`
- Criar callback `_onViewModelChange() => setState(() {})`

**Padrão de implementação:**

```dart
class TransactionsView extends StatefulWidget {
  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  late final TransactionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionsViewModel();
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI implementation
  }
}
```

### Injeção de Dependências com GetIt

- **Service Locator**: Configurado em `lib/locator.dart`
- Serviços registrados como lazy singletons na função `setupLocator()`
- Inicializado em `main()` antes de rodar o app

**Serviços registrados:**

```dart
Final<void> setupLocator() async {
  // Storage service
  locator.registerLazySingleton<StorageService>(
    () => FirebaseStorageService(),
  );

  // Auth service com dependência de storage
  locator.registerLazySingleton<AuthService>(
    () => FirebaseAuthService(storage: locator<StorageService>()),
  );

  // Repositories
  locator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(storage: locator<StorageService>()),
  );
}
```

- Acessar via `locator<Service>()` nos ViewModels

### Navegação com GoRouter

#### Rotas baseadas em Enum

- Enum `Screen` em `lib/router.dart` para navegação type-safe
- Cada tela tem `_path` e opcional `parent` para rotas hierárquicas
- Acesso via `Screen.transactions.location` para caminho completo

**Exemplo de navegação:**

```dart
// Navegação simples
context.go(Screen.transactions.location);

// Navegação com dados
context.push(
  Screen.transactionEdit.location,
  extra: transaction,
);
```

### Padrão de Camada de Dados

#### DataResult<T>

Classe sealed para tratamento de erros orientado a railway (veja `lib/core/data/data_result.dart`):

```dart
// Retornar sucesso ou falha
DataResult.success(data)
DataResult.failure(failure)

// Acessar dados
result.data
result.error
result.fold(
  onSuccess: (data) => ...,
  onFailure: (error) => ...,
)
```

- Serviços retornam `Future<DataResult<T>>` para operações que podem falhar

#### Camada de Armazenamento (Storage Service)

Interface abstrata `StorageService` implementada com Firebase:

**`FirebaseStorageService`** (`lib/services/storage/impl/firebase_storage_service.dart`):

- Persistência em **Cloud Firestore**
- Coleções: `users` e `transactions`
- Transações vinculadas ao usuário autenticado via `userId`
- Filtragem por período de datas
- Cálculo de saldo agregado

#### Camada de Repositório

**`TransactionRepository`** (`lib/repositories/transaction_repository.dart`):

- Interface abstrata para operações de transações
- Implementação: `TransactionRepositoryImpl`
- Utiliza `StorageService` internamente
- Retorna `DataResult<T>` para todas as operações
- Geração de IDs com UUID v7 (`uuid` package)

**Operações disponíveis:**

- `getTransactions()` - Listar com filtro de datas opcional
- `createTransaction()` - Criar nova transação
- `updateTransaction()` - Atualizar existente
- `deleteTransaction()` - Remover por ID
- `getBalance()` - Obter saldo total

### Imagens (Avatar) — Diretrizes

Para imagens pequenas (por exemplo, o avatar do usuário), adotamos um serviço
específico da feature, apoiado por utilitários reutilizáveis. Isso evita
duplicação e mantém clareza nas chamadas da UI.

#### Decisão de design

- Manter um `ProfileImageService` (API de alto nível da feature).
- Extrair utilitários genéricos para compressão e persistência em base64.

#### Componentes sugeridos (reutilizáveis)

- `ImageCompressor` (utilitário):
  - Redimensiona e recomprime (`jpeg`) imagens pequenas.
  - Assinatura sugerida: `compress(XFile file, {maxWidth=128, maxHeight=128, quality=70}) → Future<Uint8List>`.
- `Base64FieldStore` (adaptador Firestore):
  - Lê/escreve um campo `String` base64 em `collection/docId/field`.
  - Valida tamanho máximo (recomendado: ≤ 200 KB para avatar, respeitando 1 MiB/doc no Firestore).
  - Métodos sugeridos:
    - `save({collection, docId, field, base64, maxBytes=200000}) → DataResult<String>`
    - `load({collection, docId, field}) → DataResult<String>`

#### Wrapper da feature

- `ProfileImageService` mantém:
  - `saveAvatar(XFile file) → DataResult<String>`
  - `loadAvatar() → DataResult<String>`
- Implementação:
  - Obtém `uid` via `FirebaseAuth.currentUser`.
  - Usa `ImageCompressor` para gerar bytes compactados.
  - Usa `Base64FieldStore` para salvar/ler `users/{uid}/avatarBase64`.

#### Quando usar Base64 vs Firebase Storage

- Base64 em Firestore:
  - Bom para imagens muito pequenas (thumbnails/avatars ≤ ~200 KB).
  - Evita chamada extra ao Storage, simplificando leitura.
- Firebase Storage:
  - Preferir para imagens médias/grandes ou não triviais.
  - Salvar apenas o `downloadURL` no Firestore.

#### Injeção de dependências (GetIt)

- Registrar utilitários como singletons/lazy singletons (ex.: `ImageCompressor`,
  `Base64FieldStore`) e a implementação de `ProfileImageService`.

#### TODOs (implementação)

1. Extrair `ImageCompressor` utilitário.
2. Extrair `Base64FieldStore` para leitura/gravação de base64.
3. Refatorar `Base64ProfileImageService` para usar os utilitários mantendo a API.
4. Registrar no `locator.dart` e ajustar ViewModels consumidores.

### Modelos e Serialização

#### json_serializable

- Usar anotação `@JsonSerializable()`
- Arquivos gerados: `*.g.dart`
- Executar: `dart run build_runner build`

**Padrão:**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final String id;
  final double amount;
  
  TransactionModel({required this.id, required this.amount});
  
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
```

#### Conversores Customizados

Para tipos complexos, implemente `JsonConverter<T, S>`:

```dart
class TransactionCategoryConverter 
    implements JsonConverter<TransactionCategory, String> {
  // implementação
}
```

## Convenções Importantes

### Estilo de Código

- **Limite de 80 caracteres por linha** (aplicado via `analysis_options.yaml`)
- **Preferir construtores const** onde possível (regra de linter habilitada)
- **Preservar vírgulas finais** em estruturas multi-linha
- Usar `import 'package:financy_control/...';` para imports absolutos

### Padrão de Extensions

Extensions customizadas em `lib/core/extensions.dart`:

- `Notifiers.rebuild()`: `notifyListeners()` seguro com logging
- `String.capitalize()`: Primeira letra maiúscula

### ValueNotifier para Sub-estados

- Usar `ValueNotifier<T>` para atualizações granulares da UI sem rebuilds completos
- Exemplo: `selectedDate` e `selectedCategory` em `TransactionsViewModel`
- Envolver com `ValueListenableBuilder` na UI para rebuilds eficientes

## Configuração do Firebase

### Arquivos de Configuração

- `firebase_options.dart` - Gerado pelo FlutterFire CLI
- `android/app/google-services.json` - Configuração Android
- `firebase.json` - Configuração de hosting/deploy
- `firestore.rules` - Regras de segurança do Firestore

### Inicialização

O Firebase é inicializado em `main()` antes de executar o app:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  runApp(MyApp());
}
```

### Dependências Firebase

```yaml
firebase_core: ^4.2.1      # Core do Firebase
firebase_auth: ^6.1.2      # Autenticação
cloud_firestore: ^6.1.0    # Banco de dados
```

## Fluxos de Desenvolvimento

### Executar o App

```bash
flutter run
# Ou usar configurações de launch em .vscode/launch.json
```

### Gerar Código

```bash
# Gerar código json_serializable
dart run build_runner build

# Modo watch para geração contínua
dart run build_runner watch --delete-conflicting-outputs
```

### Testes

#### Executar Testes

```bash
# Executar todos os testes
flutter test

# Testar arquivo específico
flutter test test/services/auth/auth_service_test.dart
```

#### Padrões de Teste com Mockito

- Usar anotação `@GenerateMocks([ClassName])`
- Gerar mocks: `dart run build_runner build`
- Fornece `MockClassName` em arquivos `*.mocks.dart`
- Usar `provideDummy<T>()` no main() do teste para tipos sealed como `DataResult`

**Exemplo:**

```dart
@GenerateMocks([AuthService])
void main() {
  provideDummy<DataResult<User>>(DataResult.success(User()));
  
  test('should authenticate user', () {
    // implementação do teste
  });
}
```

## Estado Atual e Funcionalidades Incompletas

### Autenticação com Firebase

**`AuthService`** implementado com **Firebase Authentication**:

- Interface abstrata em `lib/services/auth/auth_service.dart`
- Implementação: `FirebaseAuthService` em `lib/services/auth/impl/firebase_auth_service.dart`
- Integrado ao `StorageService` para salvar dados do usuário no Firestore

**Funcionalidades disponíveis:**

- `signUp()` - Criar conta com email/senha e salvar usuário no Firestore
- `signIn()` - Autenticar com email/senha
- `signOut()` - Deslogar e limpar SharedPreferences
- `forgotPassword()` - Enviar email de recuperação de senha
- `updateUserName()` - Atualizar nome do usuário
- `updateUserPassword()` - Alterar senha
- `validateCurrentUser()` - Verificar se usuário está autenticado (com SharedPreferences)
- `currentUser` - Getter para obter usuário atual

**Tratamento de erros:**

- Classe `FirebaseAuthFailure` implementa `Failure`
- Captura `FirebaseAuthException` e retorna mensagens amigáveis
- Retorna `DataResult<T>` para todas as operações

### Persistência de Dados

**Cloud Firestore:**

- Armazenamento remoto em tempo real
- Coleção `users`: Dados dos usuários (name, email)
- Coleção `transactions`: Transações vinculadas por `userId`
- Queries com filtros por data e usuário

**SharedPreferences:**

- Armazenamento local do `userId` para validação de sessão
- Limpo no `signOut()`

**Firebase Authentication:**

- Gerenciamento de contas e sessões
- Display name do usuário sincronizado com Firestore

### Funcionalidades Incompletas

- Gerenciamento de categorias (rotas definidas, UI é `Placeholder`)
- Estatísticas e relatórios (rotas definidas, UI é `Placeholder`)
- Edição de perfil (rotas definidas, UI é `Placeholder`)

## Tarefas Comuns

### Adicionar Nova Feature

1. **Criar diretório**: `lib/features/[feature]/`
2. **Criar View**: `[feature]_view.dart` (StatefulWidget com listener do ViewModel)
3. **Criar ViewModel**: `[feature]_view_model.dart` (extends ChangeNotifier, usar `rebuild()`)
4. **Registrar rotas**: Adicionar ao enum `Screen` em `lib/router.dart`
5. **Configurar GoRouter**: Adicionar à configuração de rotas

### Adicionar Novo Model

1. Criar em `lib/core/models/[name]_model.dart`
2. Adicionar anotação `@JsonSerializable()`
3. Incluir `part '[name]_model.g.dart';`
4. Definir `fromJson` e `toJson`
5. Executar `dart run build_runner build`

### Adicionar Novo Service

1. Definir classe abstrata em `lib/services/[service]/[service]_service.dart`
2. Criar implementação (ex: mock, local, remote)
3. Registrar em `lib/locator.dart` com GetIt
4. Injetar em ViewModels via construtor ou acesso direto

## Arquivos de Referência

| Arquivo | Propósito |
|---------|-----------|
| `lib/main.dart` | Ponto de entrada (inicializa Firebase, configura locator, executa MaterialApp.router) |
| `lib/router.dart` | Enum Screen + configuração GoRouter |
| `lib/core/extensions.dart` | Extensions (rebuild, capitalize) |
| `lib/core/data/data_result.dart` | Tratamento de erros com railway pattern |
| `lib/locator.dart` | Injeção de dependências com GetIt |
| `lib/services/auth/auth_service.dart` | Interface do serviço de autenticação |
| `lib/services/auth/impl/firebase_auth_service.dart` | Implementação Firebase Auth |
| `lib/services/storage/storage_service.dart` | Interface do serviço de armazenamento |
| `lib/services/storage/impl/firebase_storage_service.dart` | Implementação Cloud Firestore |
| `lib/repositories/transaction_repository.dart` | Interface do repositório de transações |
| `lib/repositories/impl/transaction_repository_impl.dart` | Implementação do repositório |
| `lib/services/profile_image/profile_image_service.dart` | Interface do serviço de imagem de perfil (avatar) |
| `lib/services/profile_image/impl/base64_profile_image_service.dart` | Implementação baseada em base64/Firestore para avatar |
| `firebase_options.dart` | Configurações da plataforma Firebase |

## Melhores Práticas

### Faça

- Use `rebuild()` ao invés de `notifyListeners()` em ViewModels
- Sempre remova listeners no `dispose()` das Views
- Mantenha Views e ViewModels no mesmo diretório da feature
- Use `DataResult<T>` para operações que podem falhar
- Prefira `const` em construtores sempre que possível
- Use imports absolutos com `package:financy_control/`
- Mantenha linhas com máximo de 80 caracteres

### Evite

- Chamar `notifyListeners()` diretamente
- Esquecer de remover listeners
- Criar pastas `presentation/` separadas
- Retornar tipos nullable quando `DataResult<T>` é mais apropriado
- Ignorar o padrão de vírgulas finais
- Usar imports relativos para código do projeto
