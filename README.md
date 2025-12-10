# 📈 Investra – Stock Trading Analyzer

## 📌 Project Overview
Investra is a **multi-module Software-as-a-Service (SaaS) stock trading platform** built with Ruby on Rails.  
The platform is designed for **individual investors, associate traders, portfolio managers, and system administrators** to track trades, manage portfolios, and analyze market data with ease.  

This project was developed as part of **CS-UY 4513 – Software Engineering** under the guidance of **Professor Dr. DePasquale**.

---

## 👥 Developers
- **Chris Brasil**
- **Dhruv Gupta**  
- **Hanqi Liu**  
- **Hongyi Wu**  
- **Michael Bian**  
- **Sania K. Awale**

---

## 🚀 Features

### User & Identity Management
- **User Registration**: Secure account creation with email validation, password hashing (bcrypt), and automatic role assignment
- **Authentication & Authorization**: Session-based login/logout with role-based access control
- **Role Management**: Support for multiple roles (Trader, Associate Trader, Portfolio Manager, System Administrator)
- **User Profiles**: View and edit user information, manage team associations
- **Associate Assignment**: Managers can assign traders as associates and manage team hierarchies
- **Manager Requests**: System for traders to request manager assignment with approval workflow

### Trading & Portfolio Management
- **Stock Search & Discovery**: Search stocks by name or symbol with real-time price display
- **Buy/Sell Transactions**: Execute buy and sell orders with transaction locking for concurrency control
- **Portfolio Tracking**: View owned stocks, quantities, and real-time portfolio value
- **Transaction History**: Complete audit trail of all buy/sell transactions
- **Balance Management**: Real-time balance updates with deposit functionality
- **Credit Line**: Credit limit management for traders
- **Portfolio Simulation**: Simulate sell value calculations with tax and fee deductions
- **Watchlist**: Save and manage favorite stocks for quick access

### Market Data Integration
- **Real-Time Stock Prices**: Live price updates with configurable refresh intervals (60 seconds default)
- **Historical Price Data**: Price trend graphs with multiple timeframes (day, week, month, year)
- **Company Information**: Detailed company profiles with sector, market cap, IPO date, and descriptions
- **Stock Predictions**: ML-powered price predictions with confidence scores
- **News Integration**: Latest news articles related to stocks with source links
- **Market Data Providers**: Integration with Yahoo Finance (fallback) and Massive API (primary) for live quotes
- **Price Point Tracking**: Historical price point storage for trend analysis

### Analytics & Reporting
- **Portfolio Analytics**: Portfolio trend graphs with date range filtering (1 week, 1 month, 3 months, 1 year, all time)
- **Profit/Loss Summary**: Per-stock gain/loss calculations in dollars and percentages
- **Portfolio Diversification**: Pie charts showing sector and stock allocation percentages
- **What-If Investment Simulator**: Simulate hypothetical investments with ROI calculations
- **Historical Data API**: JSON endpoints for analytics data consumption
- **Associate Performance Tracking**: Manager dashboards for monitoring associate trader performance

### Company Management (Admin Only)
- **Company CRUD Operations**: Create, read, update company profiles
- **Ticker Management**: Unique ticker validation and management
- **Sector Classification**: Organize companies by sector
- **Market Cap Tracking**: Store and update market capitalization data

### Additional Features
- **Portfolio Visualization**: Visual representation of portfolio holdings and performance
- **Real-Time Data Updates**: Automatic price refresh and data synchronization
- **Mock Data Mode**: Development mode with simulated market data to avoid API rate limits

**For detailed feature documentation**, see [Feature Documentation](./docs/investra_features.md)

---

## 🛠️ Tech Stack
- **Language:** Ruby  
- **Framework:** Ruby on Rails 8.0.3
- **Database:** MySQL (via mysql2 gem)
- **Web Server:** Puma
- **Authentication:** bcrypt (password hashing)
- **Frontend:** Turbo Rails, Stimulus, Importmap
- **Testing:** 
  - RSpec (unit and integration tests)
  - Cucumber (BDD feature tests)
  - Capybara (browser automation)
  - Selenium WebDriver
- **Development Tools:**
  - Brakeman (security scanning)
  - RuboCop Rails Omakase (code style)
  - Debug gem
- **Deployment:** Kamal (Docker-based deployment)
- **Caching:** Solid Cache, Solid Queue, Solid Cable

---

## 📂 Project Modules

### 1. User & Identity Management
- **Models:** `User`, `Role`, `UserRole`, `Company`, `ManagerRequest`
- **Controllers:** `UsersController`, `SessionsController`, `DashboardController`
- **Features:** Registration, login/logout, role assignment, team management, profile management

### 2. Trading & Portfolio Management
- **Models:** `Stock`, `Portfolio`, `Transaction`, `CreditLine`, `Watchlist`
- **Controllers:** `StocksController`, `PortfoliosController`, `TransactionsController`, `WatchlistsController`, `CreditLineController`
- **Features:** Buy/sell orders, portfolio tracking, transaction history, balance management, watchlist

### 3. Market Data
- **Models:** `Stock`, `PricePoint`, `News`, `Company`
- **Controllers:** `StocksController`, `CompaniesController`
- **Services:** `MarketDataService`, `StockLookupService`, `SymbolValidator`, `MassiveClient`, `YahooClient`
- **Features:** Real-time prices, historical data, price trends, predictions, news integration

### 4. Analytics & Reporting
- **Controllers:** `AnalyticsController`
- **Services:** `AnalyticsService`, `PortfolioSummaryService`
- **Features:** Portfolio trends, profit/loss analysis, diversification charts, investment simulation

---

## 📊 Database Schema

### Core Models
- **users**: Email, password_digest, first_name, last_name, role, balance, company_id, manager_id
- **roles**: Name, description
- **user_roles**: Join table for many-to-many user-role relationship
- **companies**: Name, ticker (unique), sector, market_cap, domain, ipo_date, tradable
- **stocks**: Symbol (unique), name, price, available_quantity, sector, market_cap, description
- **portfolios**: User-stock relationship with quantity
- **transactions**: User, stock, quantity, transaction_type (buy/sell), price, timestamps
- **price_points**: Stock, price, recorded_at (for historical tracking)
- **news**: Stock, title, content, published_at, source, url
- **watchlists**: User, symbol (unique per user)
- **credit_lines**: User, credit_limit, credit_used
- **holdings**: User, symbol, shares, average_cost
- **trades**: User, symbol, trade_type, shares, price
- **manager_requests**: User, manager, status (pending/approved/rejected)

---

## 📡 API & Routes Overview

### Authentication Routes
- `GET /signup` - Registration form
- `POST /signup` - Create new user
- `GET /login` - Login form
- `POST /login` - Authenticate user
- `DELETE /logout` - Destroy session

### Dashboard Routes
- `GET /dashboard/trader` - Trader dashboard
- `PATCH /dashboard/trader/deposit` - Deposit funds
- `GET /dashboard/associate` - Associate trader dashboard
- `GET /dashboard/manager` - Portfolio manager dashboard
- `GET /dashboard/admin` - System administrator dashboard

### User Management Routes
- `GET /profile` - User profile
- `GET /users` - List users (admin/manager)
- `GET /users/:id` - Show user
- `GET /users/:id/edit` - Edit user form
- `PATCH /users/:id` - Update user
- `PATCH /users/:id/assign_associate` - Assign as associate
- `PATCH /users/:id/assign_admin` - Assign admin role
- `POST /users/:id/assign_as_associate` - Assign associate relationship
- `DELETE /users/:id/remove_associate` - Remove associate relationship
- `GET /user_management` - User management interface
- `GET /manage_team` - Team management interface

### Stock Routes
- `GET /stocks` - List all stocks with search
- `GET /stocks/:id` - Stock details with price trends, news, predictions
- `POST /stocks/:id/buy` - Buy stock
- `POST /stocks/:id/sell` - Sell stock
- `POST /stocks/:id/predict` - Get ML prediction
- `POST /stocks/:id/refresh` - Refresh stock data

### Portfolio Routes
- `GET /portfolio` - User portfolio view
- `GET /credit_line` - Credit line information

### Watchlist Routes
- `GET /watchlist` - User watchlist
- `POST /watchlist` - Add to watchlist
- `DELETE /watchlist/:symbol` - Remove from watchlist

### Transaction Routes
- `GET /transactions` - Transaction history

### Company Routes (Admin Only)
- `GET /companies` - List companies
- `GET /companies/new` - New company form
- `POST /companies` - Create company
- `GET /companies/:id` - Show company
- `GET /companies/:id/edit` - Edit company form
- `PATCH /companies/:id` - Update company

### Analytics Routes
- `GET /analytics` - Analytics dashboard
- `GET /analytics/simulate` - Investment simulator
- `POST /analytics/simulate` - Run simulation
- `GET /api/analytics/historical_data` - Historical data API endpoint

### Manager Request Routes
- `POST /manager_requests/:id/approve` - Approve manager request
- `POST /manager_requests/:id/reject` - Reject manager request

---

## 🧪 Testing

### Test Suite
- **RSpec**: Unit tests for models and request specs for controllers
- **Cucumber**: BDD feature tests covering all major user stories
- **Test Coverage**: Features include:
  - User registration and authentication
  - Buying and selling stocks
  - Portfolio management
  - Market data display
  - Company management (admin)
  - Analytics and visualization
  - Watchlist functionality
  - Credit line management
  - Associate assignment
  - Manager requests

### Running Tests
```bash
# Run RSpec tests
docker compose run --rm web bundle exec rspec

# Run Cucumber tests
docker compose run --rm web bundle exec cucumber

# Run specific feature
docker compose run --rm web bundle exec cucumber features/company_management.feature
```

---

## 🔧 Services Architecture

### Core Services
- **AnalyticsService**: Portfolio analytics, profit/loss calculations, diversification analysis
- **MarketDataService**: Orchestrates market data fetching from multiple providers
- **StockLookupService**: Stock symbol resolution and validation
- **PortfolioSummaryService**: Portfolio value calculations and summaries
- **CreditLineService**: Credit limit management and validation
- **SymbolValidator**: Stock symbol format validation

### Market Data Providers
- **MassiveClient**: Primary provider for live stock quotes (requires `MASSIVE_API_KEY`)
- **YahooClient**: Fallback provider for stock data (no API key required)

---

## ▶️ Local Development Setup

### Prerequisites
- Docker Desktop (or Docker Engine) with Compose plugin
- Ports 3000 (Rails) and 3307 (MySQL) available

### Quick Start
```bash
cd investra
docker compose up --build
```

### Access Points
- **Rails App**: http://localhost:3000
- **MySQL**: `127.0.0.1:3307` (user: `investra`, password: `investra`, root: `root`)

### Default Admin Credentials (Development/Test)
- **Email**: `admin@example.com`
- **Password**: `password`

### Environment Variables
- `MASSIVE_API_KEY`: API key for Massive market data provider (optional)
- `MASSIVE_API_BASE`: Override base URL for Massive API (defaults to `https://api.polygon.io`)
- `USE_MOCK_DATA`: Enable mock data mode for testing (set to `true`)

### Useful Commands
```bash
# Stop containers (keep volumes)
docker compose down

# Reset database
docker compose down -v

# Run tests
docker compose run --rm web bundle exec rspec
docker compose run --rm web bundle exec cucumber

# Check database
docker compose exec db mysql -uroot -proot -e "SHOW DATABASES;"
```

For detailed setup instructions, see [investra/README.md](./investra/README.md)

---

## 📚 Documentation

### Feature Documentation
- [Market Data](./docs/market_data.md)
- [Buying and Selling](./docs/buying_and_selling.md)
- [Portfolio Management](./docs/portfolio_management.md)
- [Portfolio Visualization](./docs/portfolio_visualization.md)
- [Company Management](./docs/company_management.md)
- [User Registration](./docs/user_registration.md)
- [User Login/Logout](./docs/user_loginlogout.md)
- [All Features Overview](./docs/investra_features.md)

### Additional Documentation
- [Mock Data Mode](./investra/MOCK_DATA_README.md) - Using mock data for development/testing

---

## 📦 Deliverables
- Complete source code with proper documentation  
- API documentation  
- BDD feature specifications (Cucumber)
- Unit and integration tests (RSpec)
- Final project presentation and demo  

---

## 📅 Course Information
- **Course:** CS-UY 4513 – Software Engineering  
- **Professor:** Dr. DePasquale  
- **Date:** September 27, 2025  

---

## 🔐 Security Features
- Password hashing with bcrypt
- Session-based authentication
- Role-based access control (RBAC)
- SQL injection protection via ActiveRecord
- CSRF protection (Rails default)
- Secure parameter filtering

---

## 🚀 Deployment
- **Platform**: Docker-based deployment via Kamal
- **Database**: MySQL with persistent volumes
- **Web Server**: Puma with Thruster for asset acceleration
- **Caching**: Solid Cache for Rails cache
- **Background Jobs**: Solid Queue
- **WebSockets**: Solid Cable for Action Cable

---
