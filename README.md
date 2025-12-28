# FamilyCloudApp

# Struttura
## La struttura tiene conto di:
- App Flutter per UI mobile + desktop
- Backend interno in Flutter
- Nextcloud AIO accessibile solo tramite VPN Twingate
- Upload automatico di file/media

# Architettura MVC + Service Layer
## Struttura cartelle del progetto
FamilyCloudApp/
│
├── lib/
│   ├── main.dart
│   ├── views/                      # Schermate e widget
│   │   ├── widget/                     # Widget
│   │   │   ├── vpn_status_widget.dart
│   │   │   ├── login_widget.dart
│   │   │   ├── file_selector_widget.dart
│   │   │   ├── media_gallery_widget.dart
│   │   │   └── upload_status_widget.dart
│   │   ├── hamburger_view.dart
│   │   ├── home_view.dart
│   │   ├── login_view.dart
│   │   ├── vpn_required_view.dart
│   │   ├── file_browser_view.dart
│   │   ├── media_gallery_view.dart
│   │   └── upload_status_view.dart
│   │
│   ├── controllers/                # Flutter controller / ViewModel
│   │   ├── app_controller.dart
│   │   ├── auth_controller.dart
│   │   ├── vpn_controller.dart
│   │   ├── file_controller.dart
│   │   └── upload_controller.dart
│   │
│   ├── models/                     # Flutter Model (mirroring Core)
│   │   ├── user_model.dart
│   │   ├── file_item.dart
│   │   ├── folder_item.dart
│   │   ├── upload_task.dart
│   │   ├── vpn_status.dart
│   │   └── app_settings.dart
│   │
│   ├── infrastructures/            # Basso livello
│   │   ├── http_client_factory.dart      # Gestione certificati
│   │   ├── certificate_handler.dart
│   │   ├── secure_storage.dart           # Salvataggio token sicuro
│   │   └── file_system_provider.dart
│   │
│   ├── utils/
│   │   └── logger.dart
│   │
│   └── services/
│       ├── auth_service.dart           # Login + App Password
│       ├── web_dav_service.dart        # File e cartelle
│       ├── upload_service.dart         # Upload queue / retry / chunk
│       └── vpn_detection_service.dart
│
├── pubspec.yaml
├── README.md
└── LICENSE

# Tecnologie principali
Componente	Tecnologia / Libreria
- UI Mobile/Desktop	Flutter (Android, Windows, macOS, iOS)
- Backend interno	Flutter (Android, Windows, macOS, iOS)
- HTTP / WebDAV	HttpClient Flutter (Android, Windows, macOS, iOS), gestione chunked upload
- Autenticazione	App Password Nextcloud (OCS API)
- VPN Detection	Controllo reachability IP / Twingate status
- Storage sicuro	SecureStorage (Flutter)
- File System	FileSystemProvider (cross-platform)
- Logging / Utils	Logger.dart (Flutter logger)
- Gestione certificati	HttpClientFactory + CertificateHandler (Flutter), accettazione self-signed

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
- auth_service	Richiesta App Password, gestione token
- web_dav_service	Operazioni file/cartelle via WebDAV
- upload_service	Upload queue, retry, chunked, progress
- vpn_detection_service	Verifica VPN / server raggiungibile
- infrastructure_service	HttpClientFactory, gestione certificati, SecureStorage, FS access

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
