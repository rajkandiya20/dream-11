# Dream Team Fantasy

A Fantasy Cricket Platform built with Flutter, using Clean Architecture principles with Riverpod state management.

## Architecture

This project follows **Clean Architecture** with the following structure:

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/           # App-wide constants and environment config
│   ├── network/             # Dio HTTP client and Supabase client
│   ├── router/              # GoRouter navigation configuration
│   ├── storage/             # Hive local storage management
│   ├── theme/               # Design system (colors, typography, spacing)
│   └── utils/               # Date utils, validators, extensions
├── features/                # Feature modules (Clean Architecture)
│   ├── auth/                # Authentication (login, register, forgot password)
│   ├── home/                # Home screen with match feed
│   ├── matches/             # Match listing and details
│   ├── contests/            # Contest listing and details
│   ├── fantasy/             # Fantasy team creation and management
│   ├── wallet/              # Wallet, deposits, withdrawals
│   ├── groups/              # Social groups
│   ├── profile/             # User profile management
│   ├── notifications/       # Push and in-app notifications
│   └── admin/               # Admin dashboard and management
└── shared/                  # Shared widgets and components
    ├── widgets/             # Reusable UI widgets
    └── components/          # Higher-level composed components
```

Each feature follows the layered architecture pattern:
```
feature/
├── data/
│   ├── datasources/         # Remote and local data sources
│   ├── models/              # Data models (JSON serialization)
│   └── repositories/        # Repository implementations
├── domain/
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business logic use cases
└── presentation/
    ├── providers/           # Riverpod providers
    ├── screens/             # Screen widgets
    └── widgets/             # Feature-specific widgets
```

## Tech Stack

- **Framework:** Flutter 3.16+
- **State Management:** Riverpod (flutter_riverpod + riverpod_annotation)
- **Navigation:** GoRouter
- **Networking:** Dio + Supabase Flutter
- **Local Storage:** Hive
- **Authentication:** Firebase Auth
- **Backend:** Supabase (PostgreSQL with real-time)
- **Code Generation:** Freezed, JSON Serializable, Riverpod Generator
- **Charts:** FL Chart
- **Animations:** Flutter Animate

## Design System

| Token       | Value     |
|-------------|-----------|
| Primary     | `#E11D48`  |
| Secondary   | `#0F172A`  |
| Success     | `#22C55E`  |
| Warning     | `#F59E0B`  |
| Info        | `#3B82F6`  |
| Background  | `#F8FAFC`  |
| Card        | `#FFFFFF`  |

- **Body Font:** Inter
- **Heading Font:** Poppins

## Getting Started

### Prerequisites

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android Studio / VS Code with Flutter plugin
- A Supabase project (see `sql/` for database setup)
- A Firebase project for authentication

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd dream-11
   ```

2. Copy the environment file and fill in your credentials:
   ```bash
   cp .env.example .env
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run code generation (for Freezed models, JSON serialization, Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Set up the database by running the SQL files in order:
   ```
   sql/part1-drop-and-create-tables.sql
   sql/part2-indexes-rls-realtime.sql
   sql/part3-test-data.sql
   ```

6. Run the app:
   ```bash
   flutter run
   ```

### Build with Environment Variables

Pass environment variables at build time:
```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_AUTH_DOMAIN=your_domain \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id
```

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## Database

The application uses Supabase (PostgreSQL) with the following tables:

- `users` - User accounts and profiles
- `admins` - Admin accounts with permissions
- `tournaments` - Cricket tournaments
- `teams` - Cricket teams
- `players` - Cricket players with roles and stats
- `matches` - Match schedule and results
- `match_players` - Players assigned to specific matches
- `contests` - Fantasy contests (paid/free)
- `fantasy_teams` - User-created fantasy teams
- `fantasy_team_players` - Players in fantasy teams
- `feed_posts` - Social feed posts
- `groups` - User groups
- `group_members` - Group membership
- `wallets` - User wallet balances
- `transactions` - Financial transactions
- `notifications` - User notifications
- `leaderboard` - Contest leaderboards
- `scoreboard` - Live match scoreboard
- `commentary` - Ball-by-ball commentary
- `payment_methods` - User payment methods

Real-time subscriptions are enabled for: matches, tournaments, contests, players, scoreboard, notifications, teams, commentary.

## License

This project is proprietary. All rights reserved.
