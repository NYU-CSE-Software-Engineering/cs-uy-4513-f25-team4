# Company Management (BDD Design) — Investra

## User Story
As an **admin**, I want to **add and update company profiles** so that **the platform always has accurate company data for trading, analytics, and market views**.

## Acceptance Criteria
1. Admin can create a new company with **Name**, **Ticker** (unique), and **Sector**; upon success, a confirmation message is shown.
2. Admin **cannot** create a company if **Ticker** already exists; an error message explains the conflict.
3. Admin can **edit** an existing company’s details (e.g., **Market Cap**, **Description**); upon success, a confirmation message is shown.
4. Non‑admin users **cannot access** the company management pages (they are redirected or see an authorization error).
5. Form validations: **Name** and **Ticker** are required; Ticker must be 1–8 uppercase letters/digits.

## MVC Outline
- **Model:** `Company(name:string, ticker:string:index{unique}, sector:string, market_cap:decimal{15,2}, description:text)`  
  - Validations: presence of name/ticker, uniqueness of ticker (case-insensitive), ticker format `/\A[A-Z0-9]{1,8}\z/`
- **Views:** `companies/index.html.erb`, `companies/new.html.erb`, `companies/edit.html.erb`, `companies/_form.html.erb`
- **Controller:** `CompaniesController` with `index`, `new`, `create`, `edit`, `update` actions; before_action to **authorize admin**

## Notes
- Keep Company Management **admin‑only**. Regular users/traders should not see these pages.
- These specs intentionally keep scope small and testable for the BDD assignment.