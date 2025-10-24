# Feature: Market Data
# Designer: Michael Bian, zb2253

## Task 1: Define Feature with a User Story

## User Story (Connextra)
As an stock trader (or general user),
I want to view complete market data for a company(company information, historical prices, price trend graphs, recent news and ML prediction)
so that I can quickly evaluate a stock and reference on related news and model predictions.

## Acceptance Criteria (SMART)
1. Happy path: Users can open the stock list page and click on a single stock to enter its details page, which displays information such as the company name and current stock price.
2. Price trend graph: The current stock details page displays a price trend graph and provides controls for switching timeframes between day, week, month, and year. When the user selects a specific timeframe, the graph updates to show only prices within the selected timeframe.
3. Machine Learning Predictions (including sad path): The stock detail page displays the current live price, a list of recent historical prices, and a link to the machine learning model's prediction (including summary text). If a model prediction is unavailable, a friendly "Prediction Not Available" message appears in the Forecast section.
4. Related news (include sad path): The stock details page lists the latest news related to the stock, with a link to the original article for each news item. If there is no relevant news for the company, the page will display a friendly "No latest news" prompt.
5. Prices are updated at a configurable interval (every 60 seconds) and reflected when the page is refreshed. In testing, we simulate this behavior by creating a new price record or news item and reloading the page; the page should display the latest data.

## Task 2: Outline the MVC Components

## Models
- A `Stock` model with `ticker:string`, `company_name:string`, `sector:string`, `nasdaq: string` and `description:text` attributes. 
- A `PricePoint`model with `stock_id:integer`, `price:decimal, precision: 12, scale: 4` and `recorded_at:datetime` attributes.
- A `News` model with `stock_id:integer`, `title:string`, `url:string`, `time_pblished:datetime`, `place_pblished:string` and `summary:text` attributes.
- A `Prediction`model with `stock_id:integer`, `predicted_price:decimal`, `horizon:integer` (based on num of days), `generated_at:datetime`, `confidence:float` and `model_used:string` attributes.

## Views
- A `stocks/index.html.erb` view — lists all stocks we are following; each shows the current price and a link to more information.
- A `stocks/show.html.erb` view — stock detail page that includes, company header (name, ticker), current price and last updated timestamp, price trend graph with timeframe controls, small historical price table, ML prediction section, histrocial news list.

## Controllers (Avoid Fat Controller)
- A `StocksController` with `index` (shows available stocks) and `show` (displays the stock detail page with all the including data) actions[.kamal](../investra/.kamal)