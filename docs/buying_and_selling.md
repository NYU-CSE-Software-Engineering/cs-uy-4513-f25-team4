#Buying and Selling

##User Story
As a registered investor,
I want to view market stocks, uy and sell them easily through the platform,
so that I can manage my investment portfolio efficiently and keep my account information up to date.

## Feature Description
The Buying and Selling feature allows users to:
- Search for specific stocks using a search box.  
- View lists of available stocks in the market and personal owned stocks.  
- View personal balance in real time.  
- Execute buy and sell transactions through interactive buttons.  
- See automatically refreshed data after each transaction (or manually refresh if needed).

1. **Stock Search and Display (H)**  
    Given the user is logged in,  
    When the user enters a stock name or symbol in the search box,  
    Then the system displays matching stocks from the market database along with current price and quantity available.

2. **Buying Stocks (H)**  
    Given the user is logged in and has sufficient balance,  
    When the user selects a stock, clicks “Buy,” and enters a valid quantity,  
    Then the system locks the transaction, deducts the total amount from the user’s balance, updates the stock database (reducing available quantity), adds the purchased quantity to the user’s portfolio, unlocks the transaction, and confirms success.

3. **Selling Stocks (H)**  
   Given the user owns sufficient quantity of a specific stock,  
   When the user clicks “Sell” and enters the desired quantity,  
   Then the system locks the transaction, removes the stock quantity from the user’s portfolio, adds the sold amount to the market database, credits the user’s balance, unlocks the transaction, and displays a confirmation.

4. **Insufficient Funds or Stock Quantity (S)**  
   Given the user tries to buy a stock with a cost higher than their available balance,  
   Or the user tries to sell more shares than they own,  
   Then the system prevents the transaction and displays an appropriate error message (“Insufficient balance” or “Insufficient shares”).

5. **Real-Time Balance and Portfolio Refresh (H)**  
   - After any buy or sell transaction,  
   - The system must update and refresh the user’s balance, owned stock list, and market stock list automatically (or allow manual refresh if necessary),  
   - So that the displayed data remains accurate and synchronized.

6. **Concurrency and Data Integrity (H)**  
   - When multiple users attempt to buy or sell the same stock simultaneously,  
   - The system must lock transactions appropriately to prevent race conditions,  
   - Ensuring that the total stock quantities and balances remain consistent.

##MVC

###Model
The feature will involve the following data models:
- **User model** with attributes: `username:string`, `email:string`, `balance:decimal`.  
- **Stock model** with attributes: `symbol:string`, `name:string`, `price:decimal`, `available_quantity:integer`.  
- **Portfolio model** linking users to owned stocks with attributes: `user_id:integer`, `stock_id:integer`, `quantity:integer`.  
- **Transaction model** with attributes: `user_id:integer`, `stock_id:integer`, `quantity:integer`, `transaction_type:string (buy/sell)`, `price:decimal`, `timestamp:datetime`.

These models handle core financial data, ownership tracking, and transaction history.


### View(s)
The following user interfaces (views) will be required:
- **stocks/index.html.erb** — displays a list of all available market stocks and a search box.  
- **portfolio/show.html.erb** — shows the user’s owned stocks, quantities, and balance.  
- **transactions/new.html.erb** — provides Buy and Sell buttons, quantity input fields, and real-time balance updates.  
- **shared/partials/_stock_list.html.erb** — a reusable component for displaying stock lists.  
- **shared/partials/_alerts.html.erb** — displays error or success messages after transactions.

These views ensure a clear, interactive UI for searching, buying, and selling stocks.


### Controller(s)
The following controllers and actions will manage the feature’s functionality:
- **StocksController**
  - `index` — list available market stocks and handle search queries.  
  - `refresh` — update stock list and prices from the database.  

- **PortfolioController**
  - `show` — display the user’s owned stocks and balance.  

- **TransactionsController**
  - `buy` — handle stock purchase logic (balance deduction, quantity addition).  
  - `sell` — handle stock selling logic (balance update, stock return to market).  
  - `create` — log each completed transaction in the database.  
  - `rollback` — handle failed transactions or concurrency errors.
