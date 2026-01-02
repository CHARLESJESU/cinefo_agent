# **CINEFO AGENT - Complete Project Documentation**

## **📋 Table of Contents**
1. [Project Overview](#project-overview)
2. [Project Architecture](#project-architecture)
3. [Core Files & Their Purpose](#core-files--their-purpose)
4. [Directory Structure Explained](#directory-structure-explained)
5. [Application Flow](#application-flow)
6. [File Dependencies & Connections](#file-dependencies--connections)
7. [Key Features](#key-features)
8. [Database Schema](#database-schema)
9. [API Integration](#api-integration)
10. [How to Get Started](#how-to-get-started)

---

## **📱 Project Overview**

### **What is Cinefo Agent?**
Cinefo Agent is a **Flutter mobile application** designed for film production management. It serves as a comprehensive tool for **agents, drivers, and in-charge personnel** to manage various aspects of film production including:
- **Attendance tracking** using NFC technology
- **Call sheet management** (daily shooting schedules)
- **Trip/transport management**
- **Production configuration**
- **Reporting and analytics**

### **Project Details**
- **Name**: production (package name)
- **Version**: 2.0.5+8
- **Platform**: Flutter (SDK: ^3.6.1)
- **Primary Users**: Film Production Agents, Drivers, and In-charge Personnel
- **Backend**: VFramework API (https://devvgate.vframework.in)

### **Key Technologies**
- **Framework**: Flutter/Dart
- **Local Database**: SQLite (for offline data persistence)
- **Location Services**: Geolocator, Geocoding
- **NFC**: NFC Manager (for attendance tracking)
- **State Management**: Provider pattern
- **HTTP Client**: http package
- **Background Tasks**: WorkManager
- **Updates**: In-app update support

---

## **🏗️ Project Architecture**

The project follows a **feature-based modular architecture** with clear separation of concerns:

```
lib/
├── main.dart                    # Application entry point
├── variables.dart               # Global state/configuration
├── ApiCalls/                    # API services
├── Screens/                     # UI screens organized by feature
│   ├── splash/                  # App initialization
│   ├── Login/                   # Authentication
│   ├── Route/                   # Navigation/routing screens
│   ├── Home/                    # Dashboard screens
│   ├── Attendance/              # NFC-based attendance
│   ├── callsheet/               # Call sheet management
│   ├── Trip/                    # Trip/transport management
│   ├── report/                  # Reports and analytics
│   ├── configuration/           # Production setup
├── Profile/                     # User profile
├── service/                     # Background services
├── dialogboxfunction/           # Shared dialogs
├── datafetchfromsqlite.dart     # SQLite data retrieval
└── sessionexpired.dart          # Session management
```

---

## **📂 Core Files & Their Purpose**

### **🔹 Root Level Files**

#### **1. `main.dart`** 
**Purpose**: Application entry point
- Initializes the Flutter app
- Starts background sync service (`IntimeSyncService`)
- Sets up navigation observers
- Defines the root MaterialApp widget
- Routes to `SplashScreen` as the home screen

**Connected Files**:
- `Screens/splash/splashscreen.dart` - First screen loaded
- `Screens/Attendance/dailogei.dart` - For IntimeSyncService
- `variables.dart` - For routeObserver

**Why**: This is where the app lifecycle begins. It bootstraps the entire application.

---

#### **2. `variables.dart`**
**Purpose**: Global state management and configuration
- Stores all global variables and state
- API endpoint URLs (dev and production)
- User session data (vmid, vsid, unitid, projectId, etc.)
- Text controllers for forms
- Configuration constants (unit IDs, allowance IDs)
- Asset paths for logos and images
- Route observer for navigation tracking

**Connected Files**: 
- **Used by EVERY file** in the project that needs global state
- Most important connections:
  - `loginscreen.dart` - Stores login data
  - `splashscreen.dart` - Reads session data
  - `apicall.dart` - Uses API endpoints
  - All screens - Access user data

**Why**: Centralized configuration makes it easy to manage app-wide state and settings.

---

#### **3. `datafetchfromsqlite.dart`**
**Purpose**: Quick SQLite data retrieval utility
- Fetches login data from local SQLite database
- Loads data into global variables
- Used for quick data access without full database initialization

**Connected Files**:
- `variables.dart` - Stores fetched data
- `Screens/Attendance/dailogei.dart` - Uses this for attendance sync

**Why**: Provides a simple way to quickly load essential data from SQLite.

---

#### **4. `sessionexpired.dart`**
**Purpose**: Session expiration handling screen
- Displays when user session expires
- Shows session expired image/message
- Provides button to return to login screen

**Connected Files**:
- `Screens/Login/loginscreen.dart` - Navigates back to login
- API services - Navigate here on session errors

**Why**: Ensures security by forcing re-authentication when sessions expire.

---

### **🔹 Screens Directory**

#### **5. `Screens/splash/splashscreen.dart`**
**Purpose**: App initialization and auto-login
- First screen shown on app launch
- Checks for app updates
- Initializes SQLite database
- Retrieves stored login data
- Auto-navigates to appropriate screen based on user role:
  - Agent → `RouteScreenforAgent`
  - Driver → `RouteScreenfordriver`
  - In-charge → `RouteScreenforincharge`
  - No login data → `Loginscreen`

**Connected Files**:
- `service/update_service.dart` - Checks for updates
- `Screens/Login/loginscreen.dart` - If no login data
- `Screens/Route/RouteScreenforAgent.dart` - For agents
- `Screens/Route/RouteScreenfordriver.dart` - For drivers
- `Screens/Route/RouteScreenforincharge.dart` - For in-charge
- `variables.dart` - Loads session data

**Database Operations**:
- Creates `production_login.db` database
- Creates `login_data` table with user credentials and session info

**Why**: Provides seamless app startup experience with auto-login and update checks.

---

### **🔹 Login Module (Screens/Login/)**

#### **6. `Screens/Login/loginscreen.dart`**
**Purpose**: Main login screen and authentication orchestrator
- Displays login UI (mobile number, password)
- Coordinates authentication flow
- Saves login data to SQLite
- Navigates to appropriate screen based on user role

**Connected Files**:
- `login_sqlite_service.dart` - Database operations
- `login_api_service.dart` - API calls
- `login_dialog_helper.dart` - Dialog displays
- `Screens/Route/RouteScreenforAgent.dart` - Agent navigation
- `variables.dart` - Stores login response

**Why**: Main authentication screen that brings together all login-related services.

---

#### **7. `Screens/Login/login_sqlite_service.dart`**
**Purpose**: SQLite database operations for login
- Creates and manages `production_login.db` database
- Saves login credentials and session data
- Retrieves stored login information
- Updates login data (project selection, driver field)
- Clears login data on logout

**Database Schema** (login_data table):
```sql
CREATE TABLE login_data (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mobile_number TEXT,
  password TEXT,
  profile_image TEXT,
  vsid TEXT,
  vmid INTEGER,
  vuid INTEGER,
  unitid INTEGER,
  unit_name TEXT,
  project_id TEXT,
  registered_movie TEXT,
  production_house TEXT,
  production_type_id INTEGER,
  driver INTEGER DEFAULT 0,
  created_at TEXT
)
```

**Connected Files**:
- `loginscreen.dart` - Uses all methods
- `variables.dart` - Stores/retrieves global data

**Why**: Separates database logic from UI for better maintainability and testing.

---

#### **8. `Screens/Login/login_api_service.dart`**
**Purpose**: API calls for authentication
- Fetches base URL configuration
- Performs login API request
- Fetches driver/in-charge session data
- Extracts profile image from response

**API Endpoints Used**:
- Base URL API (gets domain configuration)
- Login API (authenticates user)
- Driver Session API (gets additional driver data)

**Connected Files**:
- `loginscreen.dart` - Calls API methods
- `variables.dart` - Uses API endpoints and stores responses

**Why**: Separates API logic from UI and database operations.

---

#### **9. `Screens/Login/login_dialog_helper.dart`**
**Purpose**: Reusable dialog components for login
- Shows loading dialogs
- Displays error messages
- Shows success confirmations
- Access denied alerts
- Generic message popups

**Connected Files**:
- `loginscreen.dart` - Uses all dialog methods
- Other screens - Can reuse these dialogs

**Why**: Centralizes UI dialog logic for consistency and reusability.

---

### **🔹 Route/Navigation Screens (Screens/Route/)**

#### **10. `Screens/Route/RouteScreenforAgent.dart`**
**Purpose**: Main navigation container for Agent users
- Bottom navigation bar with 3 tabs:
  1. **Home** - Dashboard (`MyHomescreen`)
  2. **Callsheet** - Call sheet list (`Callsheetforagent`)
  3. **Reports** - Analytics (`Reportforcallsheet`)
- Manages tab switching
- Conditional callsheet access based on project selection

**Connected Files**:
- `Screens/Home/MyHomescreen.dart` - Home tab
- `Screens/callsheet/callsheetforagent.dart` - Callsheet tab
- `Screens/report/reportforcallsheet.dart` - Reports tab
- `variables.dart` - Checks productionTypeId, selectedProjectId

**Why**: Provides structured navigation for agent users.

---

#### **11. `Screens/Route/RouteScreenfordriver.dart`**
**Purpose**: Main navigation container for Driver users
- Similar structure to Agent screen but with driver-specific features
- Different home screen and features

**Connected Files**:
- Driver-specific screens
- `variables.dart`

**Why**: Separate navigation for driver role with different features.

---

#### **12. `Screens/Route/RouteScreenforincharge.dart`**
**Purpose**: Main navigation container for In-charge users
- Management and oversight features
- Approval workflows

**Connected Files**:
- In-charge specific screens
- `variables.dart`

**Why**: Separate navigation for in-charge role with management features.

---

### **🔹 Home Screens (Screens/Home/)**

#### **13. `Screens/Home/MyHomescreen.dart`**
**Purpose**: Main dashboard for Agent users
- Displays profile information
- Shows available features/actions
- Quick access to common tasks
- Project selection (for production type 3)

**Connected Files**:
- `Screens/Attendance/intime.dart` - Mark attendance
- `Screens/callsheet/callsheetforagent.dart` - View callsheets
- `Screens/configuration/configuration.dart` - Configuration
- `Profile/profilesccreen.dart` - Profile
- `variables.dart` - User data

**Why**: Central hub for agent users to access all features.

---

#### **14. `Screens/Home/driverhomescreen.dart`**
**Purpose**: Dashboard for Driver users
- Driver-specific features
- Trip management access
- OTP verification

**Connected Files**:
- Driver-specific features
- `Screens/Home/otpscreen.dart` - OTP verification

**Why**: Customized dashboard for driver role.

---

#### **15. `Screens/Home/otpscreen.dart`**
**Purpose**: OTP verification for trip completion
- Validates OTP for trip end
- Updates trip status via API

**Connected Files**:
- `ApiCalls/apicall.dart` - otpupdateapi
- `variables.dart` - Session data

**Why**: Security measure for trip completion verification.

---

#### **16. `Screens/Home/nfcUIDreader.dart`**
**Purpose**: NFC card reading for attendance
- Reads NFC tags
- Processes UID data
- Connects to attendance marking

**Connected Files**:
- `Screens/Attendance/dailogei.dart` - Marks attendance
- `Screens/Attendance/encryption.dart` - Decrypts NFC data

**Why**: Enables NFC-based attendance marking.

---

#### **17. `Screens/Home/colorcode.dart`**
**Purpose**: Color constants for UI theming
- Defines color palette
- Ensures consistent UI colors

**Connected Files**:
- All UI screens

**Why**: Centralized color management for consistent design.

---

### **🔹 Attendance Module (Screens/Attendance/)**

#### **18. `Screens/Attendance/dailogei.dart`**
**Purpose**: Core attendance marking logic and background sync
- Shows attendance marking dialog
- Captures GPS location
- Marks attendance via API
- Saves attendance to local SQLite (`intime_data` table)
- **Background sync service** (`IntimeSyncService`):
  - Runs every 15 minutes
  - Syncs pending attendance records to server
  - FIFO queue processing

**Database Schema** (intime_data table):
```sql
CREATE TABLE intime_data (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vcid TEXT,
  rfid TEXT,
  location TEXT,
  latitude REAL,
  longitude REAL,
  attendance_status TEXT,
  posted INTEGER DEFAULT 0,
  created_at TEXT
)
```

**Connected Files**:
- `Screens/Attendance/encryption.dart` - Decrypts NFC data
- `ApiCalls/apicall.dart` - datacollectionapi
- `variables.dart` - Session data
- `datafetchfromsqlite.dart` - Fetches session data

**Why**: Critical feature for attendance tracking with offline support.

---

#### **19. `Screens/Attendance/intime.dart`**
**Purpose**: In-time attendance UI and initiation
- Shows attendance marking interface
- Initiates NFC reading
- Triggers attendance dialog

**Connected Files**:
- `Screens/Attendance/dailogei.dart` - Attendance marking
- `Screens/Attendance/nfcnotifier.dart` - NFC state management

**Why**: User interface for starting attendance marking.

---

#### **20. `Screens/Attendance/outtimecharles.dart`**
**Purpose**: Out-time/checkout attendance
- Records checkout time
- Updates attendance status

**Connected Files**:
- Similar to intime.dart structure
- `Screens/Attendance/dailogei.dart`

**Why**: Completes attendance cycle with checkout tracking.

---

#### **21. `Screens/Attendance/encryption.dart`**
**Purpose**: NFC data encryption/decryption
- Decrypts encrypted NFC tag data
- Validates decrypted data
- Security for attendance system

**Connected Files**:
- `ApiCalls/apicall.dart` - decryptapi
- `Screens/Attendance/dailogei.dart` - Uses decrypted data

**Why**: Ensures security of NFC-based attendance data.

---

#### **22. `Screens/Attendance/nfcnotifier.dart`**
**Purpose**: NFC state management with Provider
- Manages NFC availability state
- Notifies UI of NFC status changes

**Connected Files**:
- All attendance screens that use NFC

**Why**: Reactive state management for NFC functionality.

---

### **🔹 Call Sheet Module (Screens/callsheet/)**

#### **23. `Screens/callsheet/callsheetforagent.dart`**
**Purpose**: Call sheet list for agents
- Displays list of call sheets (daily shooting schedules)
- Shows call sheet status
- Navigates to call sheet details

**Connected Files**:
- `Screens/callsheet/callsheet_detail.dart` - Detail view
- `ApiCalls/apicall.dart` - lookupcallsheetapi
- `variables.dart` - Project data

**Why**: Agents can view and manage their call sheets.

---

#### **24. `Screens/callsheet/callsheetforincharge.dart`**
**Purpose**: Call sheet list for in-charge users
- Similar to agent view but with management features
- Approval capabilities

**Connected Files**:
- `Screens/callsheet/approval_screen.dart` - Approvals
- `Screens/callsheet/callsheet_detail.dart`

**Why**: In-charge can oversee and approve call sheets.

---

#### **25. `Screens/callsheet/callsheet_detail.dart`**
**Purpose**: Detailed view of a single call sheet
- Shows all call sheet information
- Lists of actors, locations, scenes
- Production details

**Connected Files**:
- `Screens/report/callsheetmembers.dart` - View members
- `variables.dart` - Call sheet data

**Why**: Provides complete information about a specific call sheet.

---

#### **26. `Screens/callsheet/approval_screen.dart`**
**Purpose**: Call sheet approval workflow
- In-charge can approve/reject call sheets
- Approval API integration

**Connected Files**:
- `ApiCalls/apicall.dart` - approvalofproductionmanagerapi, approvalofproductionmanager2api

**Why**: Management oversight and approval process.

---

### **🔹 Reports Module (Screens/report/)**

#### **27. `Screens/report/reportforcallsheet.dart`**
**Purpose**: Main reports screen with calendar view
- Date-wise report selection
- Navigates to specific report types

**Connected Files**:
- `Screens/report/callsheetmembers.dart` - Member reports
- `Screens/report/InchargeReports.dart` - In-charge reports
- `Screens/report/DriverReport.dart` - Driver reports

**Why**: Central hub for accessing various reports.

---

#### **28. `Screens/report/callsheetmembers.dart`**
**Purpose**: Report showing call sheet members
- Lists all members on a call sheet
- Member details and status

**Connected Files**:
- `ApiCalls/apicall.dart` - API to fetch members
- `variables.dart`

**Why**: Track who is assigned to each call sheet.

---

#### **29. `Screens/report/InchargeReports.dart`**
**Purpose**: Reports for in-charge personnel
- Overview of operations
- Team performance metrics

**Connected Files**:
- Report-specific APIs

**Why**: Management reporting and analytics.

---

#### **30. `Screens/report/DriverReport.dart`**
**Purpose**: Trip and transport reports for drivers
- Trip history
- Completed trips
- Earnings/payments

**Connected Files**:
- `ApiCalls/apicall.dart` - driverreportapi
- `variables.dart`

**Why**: Track driver activities and trips.

---

### **🔹 Trip Module (Screens/Trip/)**

#### **31. `Screens/Trip/createtrip.dart`**
**Purpose**: Create new trip/transport request
- Form to create trip
- Select locations, times, vehicles
- Submit trip request

**Connected Files**:
- `ApiCalls/apicall.dart` - Trip creation API
- `variables.dart`

**Why**: Drivers/agents can request transportation.

---

#### **32. `Screens/Trip/agenttripreport.dart`**
**Purpose**: Trip report view for agents
- View agent's trips
- Trip status tracking

**Connected Files**:
- Trip APIs
- `variables.dart`

**Why**: Agents can track their transportation requests.

---

#### **33. `Screens/Trip/inchargereport.dart`**
**Purpose**: Trip oversight for in-charge
- All trips overview
- Trip approval/management

**Connected Files**:
- Trip APIs
- `variables.dart`

**Why**: In-charge can manage all trips.

---

### **🔹 Configuration Module (Screens/configuration/)**

#### **34. `Screens/configuration/configuration.dart`**
**Purpose**: Production configuration management
- Set up production units
- Configure allowances
- Manage team structure

**Connected Files**:
- `Screens/configuration/individualunitpage.dart` - Unit details
- `Screens/configuration/unitmemberperson.dart` - Member management
- `ApiCalls/apicall.dart` - Configuration APIs
- `variables.dart` - Configuration IDs

**Why**: Set up and manage production structure.

---

#### **35. `Screens/configuration/individualunitpage.dart`**
**Purpose**: Individual unit configuration details
- Edit unit settings
- View unit members

**Connected Files**:
- `Screens/configuration/unitmemberperson.dart` - Member list
- `variables.dart`

**Why**: Detailed unit management.

---

#### **36. `Screens/configuration/unitmemberperson.dart`**
**Purpose**: Manage members within a unit
- Add/remove members
- Assign roles

**Connected Files**:
- Configuration APIs
- `variables.dart`

**Why**: Team composition management.

---

### **🔹 Profile Module (Profile/)**

#### **37. `Profile/profilesccreen.dart`**
**Purpose**: User profile display
- Show user information
- Profile picture
- Basic details

**Connected Files**:
- `Profile/changepassword.dart` - Password change
- `variables.dart` - Profile data

**Why**: Users can view their profile.

---

#### **38. `Profile/changepassword.dart`**
**Purpose**: Change user password
- Password update form
- Validation
- API call to update

**Connected Files**:
- Password update API
- `variables.dart`

**Why**: User security and account management.

---

### **🔹 API Services (ApiCalls/)**

#### **39. `ApiCalls/apicall.dart`**
**Purpose**: Centralized API service layer
- Contains all API calling functions
- Handles HTTP requests/responses
- Error handling

**API Functions**:
1. `driverreportapi()` - Fetch driver reports
2. `otpupdateapi()` - Update OTP for trip
3. `lookupcallsheetnotforattendenceapi()` - Fetch callsheets
4. `tripupdatedstatusapi()` - Update trip status
5. `decryptapi()` - Decrypt NFC data
6. `datacollectionapi()` - Mark attendance
7. `lookupcallsheetapi()` - Fetch callsheets with attendance
8. `approvalofproductionmanagerapi()` - Approve callsheet
9. `approvalofproductionmanager2api()` - Secondary approval

**Connected Files**:
- **ALL screens that make API calls**
- `variables.dart` - API endpoints and session data

**Why**: Centralized API management for consistency and maintainability.

---

### **🔹 Services (service/)**

#### **40. `service/update_service.dart`**
**Purpose**: In-app update management
- Checks for app updates on Play Store
- Performs immediate or flexible updates
- Fallback to Play Store URL

**Connected Files**:
- `Screens/splash/splashscreen.dart` - Calls on startup

**Why**: Keeps app updated with latest features and fixes.

---

### **🔹 Other Utilities**

#### **41. `dialogboxfunction/dialogfunction.dart`**
**Purpose**: Additional shared dialog functions
- (Currently empty, reserved for future dialogs)

**Connected Files**:
- Can be used by any screen

**Why**: Placeholder for shared dialog utilities.

---

#### **42. `Tesing/Sqlitelist.dart`**
**Purpose**: Testing/debugging SQLite functionality
- Development tool for database testing

**Why**: Debugging and development support.

---

## **🔄 Application Flow**

### **Flow 1: First-Time User (No Login Data)**
```
1. App Launch (main.dart)
   ↓
2. IntimeSyncService starts (background sync)
   ↓
3. SplashScreen loads
   ↓
4. SplashScreen checks for updates
   ↓
5. SplashScreen initializes database
   ↓
6. SplashScreen checks for stored login data
   ↓
7. No login data found
   ↓
8. Navigate to Loginscreen
   ↓
9. User enters credentials
   ↓
10. login_api_service.dart calls login API
    ↓
11. login_sqlite_service.dart saves login data
    ↓
12. Navigate to RouteScreenforAgent (based on role)
```

### **Flow 2: Returning User (Has Login Data)**
```
1. App Launch (main.dart)
   ↓
2. IntimeSyncService starts
   ↓
3. SplashScreen loads
   ↓
4. SplashScreen checks for updates
   ↓
5. SplashScreen initializes database
   ↓
6. SplashScreen retrieves login data from SQLite
   ↓
7. SplashScreen loads data into variables.dart
   ↓
8. Navigate directly to RouteScreenforAgent (auto-login)
   ↓
9. User sees dashboard (MyHomescreen)
```

### **Flow 3: Attendance Marking (NFC-based)**
```
1. User clicks "Mark Attendance" on MyHomescreen
   ↓
2. Navigate to intime.dart (Attendance screen)
   ↓
3. User taps NFC card to phone
   ↓
4. nfcUIDreader.dart reads NFC tag
   ↓
5. encryption.dart decrypts NFC data via decryptapi()
   ↓
6. dailogei.dart shows attendance dialog
   ↓
7. _getCurrentLocation() gets GPS coordinates
   ↓
8. checkIfAttendanceAlreadyMarked() checks SQLite
   ↓
9. markattendance() calls datacollectionapi()
   ↓
10. API response received
    ↓
11. saveIntimeToSQLite() stores attendance locally
    ↓
12. Success dialog shown
    ↓
13. IntimeSyncService syncs data in background (every 15 min)
```

### **Flow 4: Viewing Call Sheets**
```
1. User clicks "Callsheet" tab in RouteScreenforAgent
   ↓
2. Navigate to callsheetforagent.dart
   ↓
3. lookupcallsheetapi() fetches call sheets
   ↓
4. List of call sheets displayed
   ↓
5. User clicks on a call sheet
   ↓
6. Navigate to callsheet_detail.dart
   ↓
7. Detailed information displayed
```

### **Flow 5: Session Expiry**
```
1. Any API call returns session expired error
   ↓
2. Navigate to sessionexpired.dart
   ↓
3. User sees session expired message
   ↓
4. User clicks "please login again"
   ↓
5. Navigate to Loginscreen
   ↓
6. User logs in again
```

---

## **🔗 File Dependencies & Connections Map**

### **Central Hub Files (Connected to Most Files)**
1. **`variables.dart`** - Connected to ALL files (global state)
2. **`ApiCalls/apicall.dart`** - Connected to all screens that make API calls
3. **`Screens/Login/login_dialog_helper.dart`** - Used by multiple screens for dialogs

### **Authentication Chain**
```
main.dart
  → splashscreen.dart
     → loginscreen.dart
        ├── login_sqlite_service.dart
        ├── login_api_service.dart
        └── login_dialog_helper.dart
           → RouteScreenforAgent.dart
```

### **Navigation Chain**
```
RouteScreenforAgent.dart
  ├── MyHomescreen.dart (Home tab)
  │    ├── intime.dart (Attendance)
  │    ├── profilesccreen.dart (Profile)
  │    ├── configuration.dart (Config)
  │    └── [Other features]
  │
  ├── callsheetforagent.dart (Callsheet tab)
  │    └── callsheet_detail.dart
  │         └── callsheetmembers.dart
  │
  └── reportforcallsheet.dart (Reports tab)
       ├── callsheetmembers.dart
       ├── InchargeReports.dart
       └── DriverReport.dart
```

### **Attendance Flow Chain**
```
intime.dart
  → nfcUIDreader.dart
     → encryption.dart
        → dailogei.dart
           ├── apicall.dart (datacollectionapi, decryptapi)
           └── datafetchfromsqlite.dart
              → variables.dart
```

### **Database-Related Files**
```
login_sqlite_service.dart (manages production_login.db)
dailogei.dart (manages intime_data table)
datafetchfromsqlite.dart (quick data retrieval)
splashscreen.dart (database initialization)
```

### **API-Related Files**
```
ApiCalls/apicall.dart (core API functions)
  ↑
  ├── login_api_service.dart (authentication APIs)
  ├── All callsheet screens (callsheet APIs)
  ├── All Trip screens (trip APIs)
  ├── dailogei.dart (attendance APIs)
  └── All report screens (report APIs)
```

---

## **🎯 Key Features**

### **1. Multi-Role Support**
- **Agent**: Call sheet management, attendance, reports
- **Driver**: Trip management, transport coordination
- **In-charge**: Oversight, approvals, team management

### **2. Offline Support**
- SQLite database for local data storage
- Attendance marked offline, synced later
- Background sync service (IntimeSyncService)

### **3. NFC-Based Attendance**
- Secure NFC tag reading
- Encrypted data transmission
- GPS location capture
- Duplicate prevention

### **4. Real-Time Updates**
- In-app update mechanism
- Automatic check on app start
- Flexible and immediate update options

### **5. Session Management**
- Persistent login (stored in SQLite)
- Auto-login on app restart
- Session expiry handling

### **6. Production Management**
- Call sheet tracking
- Configuration management
- Team/unit organization
- Allowance configuration

### **7. Trip Management**
- Trip creation and tracking
- OTP verification for completion
- Driver reports and earnings

### **8. Reporting & Analytics**
- Date-wise reports
- Call sheet member tracking
- Driver performance
- In-charge oversight reports

---

## **💾 Database Schema**

### **Database: `production_login.db`**

#### **Table 1: `login_data`**
Stores user authentication and session data.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-increment ID |
| mobile_number | TEXT | User's mobile number |
| password | TEXT | User's password (stored securely) |
| profile_image | TEXT | Profile image URL |
| vsid | TEXT | Session ID |
| vmid | INTEGER | Member ID |
| vuid | INTEGER | User ID |
| unitid | INTEGER | Unit ID |
| unit_name | TEXT | Unit name |
| project_id | TEXT | Current project ID |
| registered_movie | TEXT | Project/movie name |
| production_house | TEXT | Production house name |
| production_type_id | INTEGER | Type of production (2=driver, 3=agent, etc.) |
| driver | INTEGER | Is driver flag (0/1) |
| created_at | TEXT | Record creation timestamp |

#### **Table 2: `intime_data`**
Stores attendance records (in-time/check-in).

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-increment ID |
| vcid | TEXT | Callsheet ID |
| rfid | TEXT | NFC RFID tag ID |
| location | TEXT | Location address |
| latitude | REAL | GPS latitude |
| longitude | REAL | GPS longitude |
| attendance_status | TEXT | Status (e.g., "In-time") |
| posted | INTEGER | Sync status (0=pending, 1=synced) |
| created_at | TEXT | Record creation timestamp |

---

## **🌐 API Integration**

### **Base URL**
- **Development**: `https://devvgate.vframework.in/vgateapi/`
- **Production**: `https://vgate.vframework.in/vgateapi/`

### **API Endpoints**

#### **1. processRequest**
- **URL**: `/processRequest`
- **Method**: POST
- **Purpose**: General API endpoint for most requests
- **Used By**: Most API functions

#### **2. processSessionRequest**
- **URL**: `/processSessionRequest`
- **Method**: POST
- **Purpose**: Session-based API requests
- **Used By**: Authenticated API calls

### **Domain Configuration**
Different base URLs for different user types:
- **Agent Dev**: `agentsmember.cinefo.club`
- **Agent Prod**: `agentmembers.cinefo.com`
- **Driver Dev**: `drivermember.cinefo.club`
- **Driver Prod**: `driversmember.cinefo.com`
- **Dancer Dev**: `dancermember.cinefo.club`
- **Dancer Prod**: `dancermember.cinefo.com`
- **Setting Dev**: `settingmember.cinefo.club`
- **Setting Prod**: `settingmember.cinefo.com`

### **API Request Format**
Most APIs use encrypted method IDs (vmetid) stored in `variables.dart`:
- `vmetid_fetch_config_unit_allowance` - Fetch configuration
- `vmetid_Fecth_callsheet_members` - Fetch callsheet members
- `vmetid_save_config` - Save configuration
- `vmetid_fetch_unit` - Fetch unit data

---

## **🚀 How to Get Started**

### **For Developers New to This Project:**

#### **Step 1: Understand the User Flow**
1. Read the [Application Flow](#application-flow) section
2. Trace the authentication flow from `main.dart` → `splashscreen.dart` → `loginscreen.dart`
3. Understand role-based navigation to different Route screens

#### **Step 2: Explore the Code**
1. Start with `main.dart` - The entry point
2. Read `variables.dart` - Understand global state
3. Look at `splashscreen.dart` - App initialization
4. Study `loginscreen.dart` and its 3 service files - Authentication flow
5. Explore `RouteScreenforAgent.dart` - Navigation structure

#### **Step 3: Understand Key Modules**
1. **Attendance**: Start with `dailogei.dart` - Most complex module
2. **Call Sheets**: Start with `callsheetforagent.dart`
3. **API Layer**: Study `ApiCalls/apicall.dart`
4. **Database**: Check `login_sqlite_service.dart`

#### **Step 4: Test Locally**
1. Install Flutter SDK (^3.6.1)
2. Run `flutter pub get` to install dependencies
3. Connect Android device or emulator
4. Run `flutter run`

#### **Step 5: Modify Features**
1. To add a new screen:
   - Create in appropriate `Screens/[module]/` directory
   - Add navigation from relevant parent screen
   - Import `variables.dart` for global state
   
2. To add a new API:
   - Add function in `ApiCalls/apicall.dart`
   - Use existing patterns for error handling
   - Store response in `variables.dart` if needed

3. To add a new database table:
   - Add creation logic in relevant SQLite service
   - Follow existing patterns

### **Common Development Scenarios**

#### **Scenario 1: Add a New Feature for Agents**
```
1. Create new screen in Screens/[feature]/
2. Add navigation option in MyHomescreen.dart
3. Create API function in apicall.dart (if needed)
4. Add database table (if needed)
5. Connect to variables.dart for state
6. Test with agent credentials
```

#### **Scenario 2: Modify Attendance Logic**
```
1. Locate logic in Screens/Attendance/dailogei.dart
2. Understand markattendance() function
3. Check datacollectionapi() in apicall.dart
4. Modify as needed
5. Test with NFC card
```

#### **Scenario 3: Add a New Report**
```
1. Create screen in Screens/report/
2. Add API function in apicall.dart
3. Add navigation from reportforcallsheet.dart
4. Display data using similar patterns
```

---

## **📝 Important Notes**

### **Security Considerations**
1. Passwords stored in SQLite (consider encryption)
2. NFC data encrypted via API
3. Session management via vsid
4. API calls use session tokens

### **Offline Functionality**
1. Login data persists in SQLite
2. Attendance can be marked offline
3. Background sync handles pending records
4. FIFO queue ensures order

### **State Management**
1. Global state in `variables.dart`
2. Provider pattern for NFC state
3. Route observer for navigation tracking

### **Code Organization**
1. Feature-based directory structure
2. Separation of concerns (UI, API, Database)
3. Reusable components (dialogs, widgets)

### **Testing Approach**
1. Test with different user roles
2. Test offline scenarios
3. Test NFC functionality
4. Test background sync

---

## **🐛 Troubleshooting**

### **Common Issues:**

1. **Login fails**: Check API endpoint in `variables.dart`
2. **Attendance not syncing**: Check `IntimeSyncService` logs
3. **NFC not working**: Verify device NFC enabled
4. **Session expires**: Check vsid validity
5. **Database errors**: Check SQLite migration

---

## **📚 Additional Resources**

### **Key Dependencies**
- **sqflite**: Local database
- **geolocator**: GPS location
- **nfc_manager**: NFC functionality
- **http**: API calls
- **provider**: State management
- **workmanager**: Background tasks
- **in_app_update**: App updates

### **Useful Files for Quick Reference**
- `variables.dart` - All global config
- `apicall.dart` - All API functions
- `login_sqlite_service.dart` - Database schema
- `dailogei.dart` - Background sync logic

---

## **✅ Conclusion**

This documentation provides a complete overview of the Cinefo Agent project. By understanding:
- The purpose of each file
- How files connect to each other
- The application flow
- The database and API structure

Any developer should be able to work on this project effectively, even without prior knowledge.

For questions or clarifications, refer to the specific file sections above or trace the code flows outlined in this documentation.

---

**Document Version**: 1.0  
**Last Updated**: December 27, 2025  
**Project Version**: 2.0.5+8
