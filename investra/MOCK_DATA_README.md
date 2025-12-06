# Mock Data Mode for Yahoo Finance API

## Overview

To avoid rate limiting issues with the Yahoo Finance API during development and testing, you can use mock/dummy data instead of making real API calls.

## How to Enable Mock Data Mode

### Option 1: Environment Variable (Recommended)

Set the `USE_MOCK_DATA` environment variable to `true`:

```bash
# In your terminal before starting Rails
export USE_MOCK_DATA=true
rails server

# Or in one line:
USE_MOCK_DATA=true rails server
```

### Option 2: Automatic in Test Environment

Mock data is automatically enabled when running in the `test` environment (for Cucumber/RSpec tests).

## How It Works

When mock data mode is enabled:
- **No API calls** are made to Yahoo Finance
- **Realistic dummy data** is generated based on the ticker symbol
- **All features work** exactly the same way, just with simulated data
- **No rate limits** - you can test as much as you want

## Supported Tickers

The mock data includes realistic base prices for popular stocks:
- **TSLA** (Tesla) - ~$250
- **AAPL** (Apple) - ~$180
- **MSFT** (Microsoft) - ~$420
- **GOOGL** (Google) - ~$140
- **AMZN** (Amazon) - ~$150
- **META** (Meta/Facebook) - ~$500
- **NVDA** (NVIDIA) - ~$800

Any other ticker symbol will use a default price of ~$100.

## Historical Data

Mock historical data:
- Generates realistic price trends with slight variations
- Creates data points based on the selected date range
- Includes open, high, low, close, and volume data
- Shows a slight upward trend over time

## Using Real API

To use the real Yahoo Finance API:

```bash
# Unset the environment variable or set it to false
unset USE_MOCK_DATA
# or
export USE_MOCK_DATA=false
rails server
```

## Visual Indicator

When mock data mode is active, you'll see a blue info banner at the top of the analytics pages indicating that mock data is being used.

## Benefits

✅ **No rate limiting** - Test as much as you want  
✅ **Fast responses** - No network delays  
✅ **Consistent data** - Same results every time (for testing)  
✅ **Works offline** - No internet connection needed  
✅ **Perfect for demos** - Reliable data for presentations  

## For Production

**Important:** Make sure `USE_MOCK_DATA` is **not** set to `true` in production! Always use real API data in production environments.

