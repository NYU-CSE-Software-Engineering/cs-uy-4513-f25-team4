# Feature: Simulate Sell Value

## User Story
**As a** portfolio owner  
**I want** to simulate how much I would earn if I sold my entire portfolio now  
**So that** I can make informed decisions about whether to sell or hold my investments after considering taxes and transaction fees  

---

## Acceptance Criteria

1. **Display Total Value**  
   - When the user selects **"Simulate Sell Value"**, the system calculates and displays the total current value of all stocks in their portfolio based on the latest market prices.

2. **Include Taxes and Fees**  
   - The system deducts a predefined **tax rate** (e.g., 15%) and a **fixed transaction fee** (e.g., \$20) from the total to show the **net profit after deductions**.

3. **Detailed Breakdown**  
   - The result must include:
     - Gross portfolio value  
     - Taxes deducted  
     - Fees deducted  
     - Final amount receivable after deductions  

4. **Error Handling (Sad Path)**  
   - If the portfolio is empty or market data is unavailable, show:  
     > *“Simulation unavailable — please check your portfolio or try again later.”*

5. **Confirmation Message**  
   - After a successful simulation, show:  
     > *“If you sold your portfolio today, your estimated return after taxes and fees would be \$XX,XXX.XX.”*

---

## MVC Component Outline

### **Model(s)**
- **`Portfolio`**
  - Associations: `has_many :stocks`, `has_one :credit_line`
  - Methods:
    - `simulate_sell_value` → Computes  
      `total = Σ(stock.quantity × stock.current_price) − tax − fees`
- **`Stock`**
  - Attributes:  
    - `name:string`  
    - `quantity:integer`  
    - `current_price:decimal`
- **`Transaction`** *(for simulated sells)*
  - Attributes:  
    - `sell_value:decimal`  
    - `taxes:decimal`  
    - `fees:decimal`  
    - `net_value:decimal`

---

### **View(s)**
- **`/portfolio/show.html.erb`**
  - Displays “Simulate Sell Value” button and result section.
- **`/portfolio/_simulation_result.html.erb`**
  - Partial rendering breakdown of gross value, taxes, fees, and final net value.
- Inline **error messages** appear under the portfolio summary when simulation fails.

---

### **Controller(s)**
- **`PortfoliosController`**
  - `show` → Renders portfolio summary and simulation button.  
  - `simulate_sell` → POST endpoint that calls `Portfolio#simulate_sell_value`, then renders the result or error.

---

**File location:**  
`docs/portoflio_management.md`

