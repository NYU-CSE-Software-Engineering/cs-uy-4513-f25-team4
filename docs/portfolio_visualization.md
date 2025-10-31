# **User Analytics Feature – Dhruv Gupta**

## **User Story**
> **As an individual investor**,  
> I want to view detailed analytics of my portfolio performance and 
simulate hypothetical investments,  
> so that I can understand my gains/losses, diversification, and how 
different investment choices could have affected my returns.

---

## **Acceptance Criteria**

### **1. Portfolio Trend Graph**
- Displays total portfolio value over time as a line chart.  
- Allows filtering by date range (1 week / 1 month / 3 months / 1 year / 
All time).  
- Updates dynamically when the user changes the range.

### **2. Profit/Loss Summary**
- Shows each stock’s gain/loss in both dollars and percent.  
- Highlights positive and negative returns in green / red.  
- Updates automatically when new trades occur or data refreshes.

### **3. Portfolio Diversification Pie Chart**
- Visualizes percentage of total portfolio invested per sector or stock.  
- Totals equal 100%.  
- If no holdings exist, displays “No data available.”

### **4. What-If Investment Simulator**
- User can enter stock symbol, amount, and start date to test scenarios 
such as:  
  *“What if I invested $5,000 in Tesla three months ago?”*  
- Displays hypothetical current value, ROI (%), and profit/loss.  
- Shows an error if fields are blank or invalid symbol is entered.  
- *(Optional)* Renders a mini chart of simulated growth.

---
Models
User, Portfolio, Holding, and Trade (existing models) will provide 
portfolio and transaction data.
Introduce a new AnalyticsService class responsible for computing total 
portfolio value trends, profit/loss summaries, sector diversification, and 
running “what-if” investment simulations using market data.

Views
app/views/analytics/index.html.erb – main analytics dashboard displaying:
• Portfolio trend graph (line chart)
• Profit/Loss summary per stock (table or bar chart)
• Portfolio diversification pie chart.
app/views/analytics/simulate.html.erb – dedicated page for the “What-if 
Investment Simulator” feature where users input a stock, amount, and start 
date to simulate hypothetical returns.

Controllers
AnalyticsController will manage analytical data display and user 
interactions.
• index – retrieves and visualizes performance analytics, charts, and 
summaries.
• simulate – handles the “What-if” simulation form, calls the service to 
calculate hypothetical ROI, and renders results.

