# 🎓 Student Community Hub

A Flutter application built for the **DafoTalk Flutter Developer Internship Assessment**.

> Built with Flutter + Supabase — featuring anonymous posts, interest groups, user profiles, and clean Provider-based state management.

---

## 📱 Features

| Feature | Description |
|---|---|
| 🔐 **User Authentication** | Register, Login, Logout via Supabase Auth |
| 💬 **Anonymous Discussion Feed** | Create and view posts — no identity revealed |
| 👥 **Student Interest Groups** | Create, join, and leave interest groups |
| 👤 **User Profile** | View and edit username and bio |
| 🎨 **Responsive UI** | Clean navigation with bottom nav bar |

---

## 🚀 Project Setup

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- A [Supabase](https://supabase.com) account with a new project

---

### Step 1 — Supabase Database Setup

Run the following SQL in your Supabase **SQL Editor**:

```sql
-- Profiles table (linked to auth.users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  username text not null,
  bio text default '',
  created_at timestamp with time zone default timezone('utc', now())
);

-- Anonymous posts table (no user_id — truly anonymous)
create table posts (
  id uuid default gen_random_uuid() primary key,
  content text not null,
  created_at timestamp with time zone default timezone('utc', now())
);

-- Interest groups table
create table groups (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text default '',
  creator_id uuid references auth.users on delete set null,
  created_at timestamp with time zone default timezone('utc', now())
);

-- Group memberships table
create table group_members (
  id uuid default gen_random_uuid() primary key,
  group_id uuid references groups on delete cascade,
  user_id uuid references auth.users on delete cascade,
  joined_at timestamp with time zone default timezone('utc', now()),
  unique(group_id, user_id)
);
```

---

### Step 2 — Row-Level Security (RLS) Policies

```sql
alter table profiles enable row level security;
alter table posts enable row level security;
alter table groups enable row level security;
alter table group_members enable row level security;

create policy "Public read" on profiles for select using (true);
create policy "Own insert" on profiles for insert with check (auth.uid() = id);
create policy "Own update" on profiles for update using (auth.uid() = id);

create policy "Public read posts" on posts for select using (true);
create policy "Authenticated insert posts" on posts for insert with check (auth.role() = 'authenticated');

create policy "Public read groups" on groups for select using (true);
create policy "Authenticated insert groups" on groups for insert with check (auth.role() = 'authenticated');

create policy "Public read members" on group_members for select using (true);
create policy "Own insert members" on group_members for insert with check (auth.uid() = user_id);
create policy "Own delete members" on group_members for delete using (auth.uid() = user_id);
```

> **Tip:** For quick local testing, you can disable RLS entirely from the Supabase dashboard.

---

### Step 3 — Add Supabase Credentials

Open `lib/core/supabase_config.dart` and replace the placeholders:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
}
```

Find these values in your Supabase dashboard under **Project Settings → API**.

---

### Step 4 — Install & Run

```bash
flutter pub get
flutter run
```

---

### Step 5 — Build Release APK

```bash
flutter build apk --release
```

APK output path:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🏗️ Architecture Overview

```
lib/
├── core/
│   └── supabase_config.dart       # Supabase URL and anon key
├── models/
│   ├── post_model.dart            # Post data model
│   ├── group_model.dart           # Group data model
│   └── profile_model.dart         # Profile data model
├── providers/
│   ├── auth_provider.dart         # Login / Register / Logout state
│   ├── post_provider.dart         # Posts CRUD
│   ├── group_provider.dart        # Groups CRUD + join/leave
│   └── profile_provider.dart      # Profile fetch/update
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── feed/
│   │   ├── feed_screen.dart
│   │   └── create_post_screen.dart
│   ├── groups/
│   │   ├── groups_screen.dart
│   │   ├── group_detail_screen.dart
│   │   └── create_group_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   └── home_screen.dart           # Bottom navigation shell
├── widgets/
│   ├── post_card.dart             # Reusable post card widget
│   └── group_card.dart            # Reusable group card widget
└── main.dart                      # Entry point + auth routing
```

### Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter |
| **Backend / Auth / DB** | Supabase (PostgreSQL) |
| **State Management** | Provider (ChangeNotifier) |
| **Navigation** | Flutter Navigator + BottomNavigationBar |

---

## 📋 Assumptions Made

- Posts are **fully anonymous** — no `user_id` is stored or displayed at any point
- Users must be **logged in** to create posts, create groups, and join/leave groups
- User profile is **auto-created** on registration
- **Email confirmation** is disabled in Supabase for faster testing (can be re-enabled in Auth settings)

---

## 🔮 Future Improvements

- [ ] Comments on posts
- [ ] Search/filter for groups
- [ ] Profile avatar upload via Supabase Storage
- [ ] Push notifications for group activity
- [ ] Post reporting / moderation system
- [ ] Pagination / infinite scroll for feed and groups
- [ ] Unit tests and widget tests

---

## 📂 Download

- 📦 **APK** — Available in [Releases](../../releases)
- 🎥 **Demo Video** — [Watch here](#) *(replace with your video link)*

---

## 👨‍💻 Author

**Raja Haris**  
COMSATS University Islamabad, Wah Campus  
Flutter Developer Internship Assessment — DafoTalk
