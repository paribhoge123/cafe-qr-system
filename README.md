# Cafe QR System

QR-based cafe ordering, payment & kitchen management system.

## Stack

| Layer | Technology |
|---|---|
| Backend | Node.js + Express + TypeScript |
| Database | PostgreSQL |
| Cache / Realtime | Redis |
| Frontend | React + Vite (PWA) |
| Payments | Razorpay |
| Auth | JWT + OTP |

## Prerequisites

- Node.js >= 20
- Docker & docker-compose
- npm >= 10

## Local setup

```bash
# 1. Clone
git clone https://github.com/paribhoge123/cafe-qr-system.git
cd cafe-qr-system

# 2. Start PostgreSQL & Redis
docker-compose up -d

# 3. Backend
cd backend
cp .env.example .env        # fill in your values
npm install
npm run migrate             # run DB migrations
npm run dev

# 4. Frontend (new terminal)
cd frontend
cp .env.example .env.local
npm install
npm run dev
```

Backend runs on http://localhost:4000  
Frontend runs on http://localhost:5173

## Branch naming

```
feature/<issue-number>-<short-description>
fix/<issue-number>-<short-description>
chore/<short-description>
```

## Commit format

```
feat(scope): description
fix(scope): description
chore(scope): description
```

## Contributors

- Parikshita ([@paribhoge123](https://github.com/paribhoge123))
- Akshad
