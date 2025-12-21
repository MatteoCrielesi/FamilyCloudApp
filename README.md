# FamilyCloudApp

# Struttura
## La struttura tiene conto di:
- App Flutter per UI mobile + desktop
- Backend interno in .NET/C#
- Nextcloud AIO accessibile solo tramite VPN Twingate
- Upload automatico di file/media

# Architettura MVC + Service Layer
## Struttura cartelle del progetto
FamilyCloudApp/
│
├── Core/                         # Backend interno (.NET/C#)
│   ├── Models/                   # Dati e stato applicativo (Model)
│   │   ├── UserModel.cs
│   │   ├── FileItem.cs
│   │   ├── FolderItem.cs
│   │   ├── UploadTask.cs
│   │   ├── VpnStatus.cs
│   │   └── AppSettings.cs
│   │
│   ├── Controllers/              # Logica applicativa (Controller)
│   │   ├── AppController.cs
│   │   ├── AuthController.cs
│   │   ├── VpnController.cs
│   │   ├── FileController.cs
│   │   └── UploadController.cs
│   │
│   ├── Services/                 # Servizi verso Nextcloud / VPN
│   │   ├── AuthService.cs        # Login + App Password
│   │   ├── WebDavService.cs      # File e cartelle
│   │   ├── UploadService.cs      # Upload queue / retry / chunk
│   │   └── VpnDetectionService.cs
│   │
│   ├── Infrastructure/           # Basso livello
│   │   ├── HttpClientFactory.cs  # Gestione certificati
│   │   ├── CertificateHandler.cs
│   │   ├── SecureStorage.cs      # Salvataggio token sicuro
│   │   └── FileSystemProvider.cs
│   │
│   └── Utils/                    # Utility varie
│       └── Logger.cs
│
├── UI/                           # Frontend Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── views/                # Schermate e widget
│   │   │   ├── login_view.dart
│   │   │   ├── vpn_required_view.dart
│   │   │   ├── file_browser_view.dart
│   │   │   ├── media_gallery_view.dart
│   │   │   └── upload_status_view.dart
│   │   │
│   │   ├── controllers/          # Flutter controller / ViewModel
│   │   │   ├── app_controller.dart
│   │   │   ├── auth_controller.dart
│   │   │   └── file_controller.dart
│   │   │
│   │   ├── models/               # Flutter Model (mirroring Core)
│   │   │   ├── file_item.dart
│   │   │   └── upload_task.dart
│   │   │
│   │   └── services/             # Bridge verso Core .NET
│   │       └── core_bridge.dart
│   │
│   └── pubspec.yaml
│
├── README.md
└── LICENSE

# Tecnologie principali
Componente	Tecnologia / Libreria
- UI Mobile/Desktop	Flutter (Android, Windows, macOS, iOS)
- Backend interno	.NET 8 / C#
- HTTP / WebDAV	HttpClient (.NET), gestione chunked upload
- Autenticazione	App Password Nextcloud (OCS API)
- VPN Detection	Controllo reachability IP / Twingate status
- Storage sicuro	SecureStorage (.NET + Flutter)
- File System	FileSystemProvider (cross-platform)
- Logging / Utils	Logger.cs (.NET), Flutter logger
- Gestione certificati	HttpClientFactory + CertificateHandler (.NET), accettazione self-signed

# Servizi e API da utilizzare
🔹 Nextcloud
Servizio	Endpoint / API	Scopo
- Autenticazione	POST /ocs/v2.php/core/getapppassword	Creazione App Password token
- File / Cartelle	PROPFIND /remote.php/dav/files/USERNAME/	Lista file e cartelle
- Upload	PUT /remote.php/dav/files/USERNAME/<path>	Upload file singolo / chunked
- Cartelle	MKCOL /remote.php/dav/files/USERNAME/<folder>	Creazione cartelle
- Download / Delete / Move	WebDAV standard	Download, cancellazione, spostamento/rinominazione

🔹 VPN (Twingate)
Non c’è API pubblica per controllare la VPN da app
### Verifica stato:
- Raggiungibilità IP interno Nextcloud (ping o HTTP request)
- Eventualmente uso OS-specific VPN detection
#### Se VPN non attiva:
Messaggio all’utente + pulsante per aprire Twingate
#### Se VPN attiva:
Schermata di login + pulsante per aprire NextCloud su browser

🔹 Backend interno / Service Layer
Servizio	Scopo
- AuthService	Richiesta App Password, gestione token
- WebDavService	Operazioni file/cartelle via WebDAV
- UploadService	Upload queue, retry, chunked, progress
- VpnDetectionService	Verifica VPN / server raggiungibile
- Infrastructure	HttpClientFactory, gestione certificati, SecureStorage, FS access

# Flusso MVC esempio (Upload automatico)
[View] FileBrowserView / MediaGalleryView
    ↓ selezione file/cartella
[Controller] FileController → UploadController
    ↓ verifica VPN
[Service] VpnDetectionService
    ↓ VPN OK
[Service] UploadService → WebDavService
    ↓ invio chunk a Nextcloud API
[Model] UploadTask aggiornato
[View] UploadStatusView aggiornata con progress

# Punti chiave
+ App monolitica → contiene UI + backend interno
+ Architettura MVC + Service Layer
+ Nextcloud = unico “server remoto” tramite VPN
+ Upload chunked per file grandi
+ Token sicuro con App Password
+ Flutter permette UI cross-platform (Android + Windows + macOS + iOS)
+ .NET C# gestisce logica e API interne
