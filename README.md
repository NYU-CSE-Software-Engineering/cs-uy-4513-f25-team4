# 📈 Investra – Stock Trading Analyzer

## 📌 Project Overview
Investra is a **multi-module Software-as-a-Service (SaaS) stock trading platform** built with Ruby on Rails.  
The platform is designed for **individual investors, associate traders, portfolio managers, and system administrators** to track trades, manage portfolios, and analyze market data with ease.  

This project was developed as part of **CS-UY 4513 – Software Engineering** under the guidance of **Professor Dr. DePasquale**.

🌐 **Live Application:** [https://investra-61e9499b805d.herokuapp.com/login](https://investra-61e9499b805d.herokuapp.com/login)

📊 **Test Coverage Report (82.64%):** [View on GitHub Pages](https://nyu-cse-software-engineering.github.io/cs-uy-4513-f25-team4/)

---

## 👥 Team Members and Contributions

| Team Member | Module | Primary Contributions |
|-------------|--------|----------------------|
| **Sania K. Awale** | User & Identity Management | User registration, authentication, role-based access control, session management, password hashing |
| **Chris Brasil** | Portfolio Management | Portfolio view, trade history, stock watchlist, credit line balance, sell simulation |
| **Dhruv Gupta** | User Analytics | Portfolio trend graphs, profit/loss summaries, diversification pie charts, what-if investment simulator |
| **Michael Bian** | Market Data | Stock information, real-time prices, price trend graphs, ML predictions, news integration, CI/CD & test coverage |
| **Hongyi Wu** | Buying & Selling | Stock search, buy/sell transactions, balance management, transaction processing |
| **Hanqi Liu** | Company Management | Company profiles, IPO listings, financial data upload, external API sync |

---

## 🛠️ Tech Stack
- **Language:** Ruby 3.2.2  
- **Framework:** Ruby on Rails 8.0.3  
- **Database:** MySQL 8.0  
- **Testing:** RSpec (TDD) + Cucumber (BDD)
- **Coverage Tool:** SimpleCov  
- **Deployment:** Heroku

---

## 🚀 Setup Instructions

### Prerequisites
- Ruby 3.2.2
- Rails 8.0.3
- MySQL 8.0
- Docker Desktop (recommended for local development)

### Option 1: Docker Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team4.git
cd cs-uy-4513-f25-team4/investra

# Build and start containers
docker compose up --build

# Access the application
open http://localhost:3000
```

### Option 2: Manual Setup

```bash
# Clone the repository
git clone https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team4.git
cd cs-uy-4513-f25-team4/investra

# Install Ruby dependencies
bundle install

# Create and setup the database
rails db:create
rails db:migrate
rails db:seed

# Start the Rails server
rails server
```

### Default Admin Login (Development/Test)
- **Email:** `admin@example.com`
- **Password:** `password`

---

## 🧪 Testing Instructions

### Run All Tests

```bash
# Using Docker (recommended)
docker compose exec web bin/run_coverage

# Or run separately:
docker compose exec web bundle exec rspec      # RSpec unit tests
docker compose exec web bundle exec cucumber   # Cucumber BDD tests
```

### Run Tests Manually (without Docker)

```bash
cd investra

# Run RSpec tests
bundle exec rspec

# Run Cucumber tests
bundle exec cucumber

# Run all tests with coverage report
bin/run_coverage
```

### View Coverage Report
After running tests, open `coverage/index.html` in your browser to view the detailed coverage report.

---

## 🚀 Features
- **User & Identity Management**  
  Secure authentication and role-based permissions for traders, associates, managers, and admins.

- **Trading & Portfolio Management**  
  Place buy/sell orders, track performance, and monitor portfolios.

- **Market Data Integration**  
  Real-time and historical stock data, financial reports, and AI/ML-powered predictions.

- **Associate Analytics**  
  Performance tracking, reporting, and dashboards for managers and system-wide analytics.
  
- **For detailed feature documentation:**  
  [Check here](./docs/investra_features.md)

---

## 📂 Project Modules
1. **User & Identity Management** – authentication, registration, role management  
2. **Trading & Portfolio Management** – order placement, portfolio tracking  
3. **Market Data** – stock information, predictions, and reports  
4. **Associate Analytics** – dashboards, performance summaries  

---

## 📡 API Overview
Each module exposes a **RESTful API** for inter-module communication and external integration.  
Some core endpoints include:

- **User API**: `/api/users/register`, `/api/users/login`, `/api/users/me`  
- **Stock Management API**: `/api/orders`, `/api/stock/sell/:id`  
- **Portfolio API**: `/api/portfolios/:userId`, `/api/portfolios/:id/holdings`  
- **Associate API**: `/api/associates`, `/api/associates/:id`  
- **Trade/Order API**: `/api/orders/:id`, `/api/orders?userId=123`  

---

## 📦 Deliverables
- Complete source code with proper documentation  
- API documentation  
- Final project presentation and demo  

---

## 📅 Course Information
- **Course:** CS-UY 4513 – Software Engineering  
- **Professor:** Dr. DePasquale  
- **Semester:** Fall 2025

---
