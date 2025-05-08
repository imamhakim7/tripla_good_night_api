# 🌙 Good Night API (Sleep Tracker)

A scalable RESTful API built with Ruby on Rails to track users' sleep activities — when they go to bed (clock in) and when they wake up (clock out).

Task: [BE interview homework_v2.pdf](./BE interview homework_v2.pdf)

## ✨ Features

- Follow and unfollow other users.
  `follow` is the `action_type` to relationable (other users) of relationships,
  so for further features we can scale to another action_type to the relationable
  e.g. - `star` to relationable users - `like` to relationable posts, activity_sessions, e.t.v
- Users can clock in and out for sleep.
- View personal sleep records sorted by time.
  `sleep` is the activity_type of the activity_sessions,
  so for further features we can scale to another activity_type, e.g. `workout`, `cycling`, `study`
- View friends’ sleep records from the previous week, sorted by duration.
- 🙋 Assumptions
  - Users are pre-created with `id` and `name`.
  - Authentication is handled via JWT with `Authorization` header.

## 🔧 Tech Stack

- Ruby on Rails API
- PostgreSQL
- JWT for authentication
- RSpec for testing
- Kaminari for pagination
- Docker-ready setup
- Redis for caching

## 📁 Project Structure

```
app/
├── controllers/
│ ├── api/
│ │ └── ...
│ │
│ └── concern/
│   └── ...
│
├── models/
│ └── ...
│
├── serializers/
│ └── ...
│
├── jobs/
│ └── ...
│
spec/
├── factories/
│ └── ...
│
├── models/
│ └── ...
│
├── requests/
│ └── ...
│
├── supports/
│ └── ...

```

## 📌 API Endpoints

### 1. Authentication

```http
POST  /api/login -> login by email and password
POST  /api/refresh -> refresh access_token
GET   /api/logout
```

### 2. Follow / Unfollow

```http
action_type = /follow/
relationable_type = \user\

POST    /api/do/:action_type/:relationable_type:user_id
DELETE  /api/do/:action_type/:relationable_type:user_id

- Auth required: ✅
```

### 3. Clock-In and Clock-Out

```http
activity_type = /sleep/

POST   /api/act/:activity_type/clock_in -> return activity_session_id
PATCH  /api/act/:activity_type/clock_out -> clock_out latest ongoing activity_session
PATCH  /clock_out/:id -> clock_out by activity_session_id

- Auth required: ✅
```

### 4. User Data

```http
activity_type = /sleep/

GET  /api/my/profile -> fetch user profile data
GET  /api/my/followers -> fetch list of user followers
GET  /api/my/followings -> fetch list of user following users
GET  /api/my/activities/:activity_type -> fetch user activity ("sleep") records
GET  /api/my/followers/activities/:activity_type -> fetch user followers activity ("sleep") records
GET  /api/my/followings/activities/:activity_type -> fetch user followings activity ("sleep") records

- Auth required: ✅
- Filter on activities:
    - filter_ongoing using params ?ongoing=yes|true|1 -> returning non clocked-out activity_session
    - filter_finished using params ?finished=yes|true|1 -> returning only finished clock-in and clock-out
    - filter_from_last_week params ?from_last_week=yes|true|1 -> returning activity_session created_at > 1.week.ago
```

### 4. Other User Data

```http
activity_type = /sleep/

GET  /api/users/:id/profile -> fetch other user profile data
GET  /api/users/:id/followers -> fetch list of other user followers
GET  /api/users/:id/followings -> fetch list of other user following users
GET  /api/users/:id/activities/:activity_type -> fetch other user activity ("sleep") records
GET  /api/users/:id/followers/activities/:activity_type -> fetch other user followers activity ("sleep") records
GET  /api/users/:id/followings/activities/:activity_type -> fetch other user followings activity ("sleep") records

- Auth required: ✅
- :id is the other user.id
- Filter on activities:
    - filter_ongoing using params ?ongoing=yes|true|1 -> returning non clocked-out activity_session
    - filter_finished using params ?finished=yes|true|1 -> returning only finished clock-in and clock-out
    - filter_from_last_week params ?from_last_week=yes|true|1 -> returning activity_session created_at > 1.week.ago
```

## 🧪 Tests

Run full request specs:

```bash
bundle exec rspec
```

- Covers all endpoints including edge cases and auth checks.

## 🚀 Quick Start

```bash
git clone https://github.com/your-repo/good-night-api.git
cd good-night-api
bundle install
rails db:create db:migrate
rails s
```

### ⚙️ Scalability

See [`SCALING.md`](./SCALING.md) for detailed strategies on performance and scaling:

- DB indexing
- Redis caching
- API pagination & filtering
- Puma concurrency & Docker
- JWT security & rate limiting
- Background jobs --> Not yet needed

## TODO:

### 📄 Api Documentations: See this!

- https://github.com/rswag/rswag
- https://github.com/Apipie/apipie-rails
