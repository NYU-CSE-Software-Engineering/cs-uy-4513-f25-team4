# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create a default company
company = Company.find_or_create_by!(name: "Default Company") do |c|
  c.sector = "Technology"
  c.market_cap = 1000000000.00
end

puts "✅ Created company: #{company.name}"

# Create users with different roles
admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.first_name = "Admin"
  u.last_name = "User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "Admin"
  u.company = company
  u.balance = 10000.00
end

trader = User.find_or_create_by!(email: "trader@example.com") do |u|
  u.first_name = "Trader"
  u.last_name = "User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "Trader"
  u.company = company
  u.balance = 50000.00
end

puts "✅ Created users: #{admin.email}, #{trader.email}"

# Create stocks with company information and market data
stocks_data = [
  {
    symbol: "AAPL",
    name: "Apple Inc.",
    price: 170.50,
    available_quantity: 10000,
    sector: "Technology",
    market_cap: 2800000000000.00,
    description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide."
  },
  {
    symbol: "GOOGL",
    name: "Alphabet Inc.",
    price: 140.25,
    available_quantity: 5000,
    sector: "Technology",
    market_cap: 1750000000000.00,
    description: "Alphabet Inc. offers various products and platforms in the United States, Europe, the Middle East, Africa, the Asia-Pacific, Canada, and Latin America."
  },
  {
    symbol: "MSFT",
    name: "Microsoft Corporation",
    price: 380.75,
    available_quantity: 8000,
    sector: "Technology",
    market_cap: 2850000000000.00,
    description: "Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide."
  },
  {
    symbol: "TSLA",
    name: "Tesla Inc.",
    price: 245.60,
    available_quantity: 3000,
    sector: "Automotive",
    market_cap: 780000000000.00,
    description: "Tesla, Inc. designs, develops, manufactures, leases, and sells electric vehicles, and energy generation and storage systems."
  },
  {
    symbol: "AMZN",
    name: "Amazon.com Inc.",
    price: 175.30,
    available_quantity: 7000,
    sector: "E-commerce",
    market_cap: 1820000000000.00,
    description: "Amazon.com, Inc. engages in the retail sale of consumer products and subscriptions in North America and internationally."
  }
]

stocks_data.each do |stock_data|
  stock = Stock.find_or_create_by!(symbol: stock_data[:symbol]) do |s|
    s.name = stock_data[:name]
    s.price = stock_data[:price]
    s.available_quantity = stock_data[:available_quantity]
    s.sector = stock_data[:sector]
    s.market_cap = stock_data[:market_cap]
    s.description = stock_data[:description]
  end
  puts "✅ Created stock: #{stock.symbol} - #{stock.name}"
end

# Create news articles for stocks
news_data = [
  {
    stock_symbol: "AAPL",
    articles: [
      {
        title: "Apple Unveils New iPhone 16 with Advanced AI Features",
        content: "Apple Inc. announced the iPhone 16 lineup today, featuring groundbreaking AI capabilities powered by the new A18 chip. The devices include improved camera systems and extended battery life.",
        published_at: 2.days.ago,
        source: "TechCrunch",
        url: "https://techcrunch.com/tag/apple/"
      },
      {
        title: "Apple Reports Record Q4 Earnings",
        content: "Apple Inc. reported its fourth quarter financial results, beating analyst expectations with revenue of $89.5 billion and earnings per share of $1.46.",
        published_at: 5.days.ago,
        source: "Reuters",
        url: "https://www.reuters.com/technology/apple/"
      },
      {
        title: "Apple Vision Pro Sees Strong Demand in Enterprise",
        content: "The Apple Vision Pro is gaining traction in enterprise markets, with major corporations adopting the spatial computing platform for training and collaboration.",
        published_at: 7.days.ago,
        source: "Bloomberg",
        url: "https://www.bloomberg.com/quote/AAPL:US"
      }
    ]
  },
  {
    stock_symbol: "GOOGL",
    articles: [
      {
        title: "Google Launches New AI-Powered Search Features",
        content: "Alphabet's Google unveiled major updates to its search engine, integrating advanced AI models to provide more accurate and contextual search results.",
        published_at: 1.day.ago,
        source: "The Verge",
        url: "https://www.theverge.com/google"
      },
      {
        title: "Alphabet Expands Cloud Computing Infrastructure",
        content: "Alphabet Inc. announced plans to invest $10 billion in data centers and cloud infrastructure across the United States.",
        published_at: 3.days.ago,
        source: "CNBC",
        url: "https://www.cnbc.com/quotes/GOOGL"
      }
    ]
  },
  {
    stock_symbol: "TSLA",
    articles: [
      {
        title: "Tesla Cybertruck Production Ramps Up",
        content: "Tesla Inc. announced that Cybertruck production has significantly increased, with the company now producing over 1,000 units per week.",
        published_at: 1.day.ago,
        source: "Electrek",
        url: "https://electrek.co/guides/tesla/"
      },
      {
        title: "Tesla Opens New Gigafactory in Texas",
        content: "Tesla inaugurated its newest manufacturing facility in Austin, Texas, which will produce batteries and electric vehicle components.",
        published_at: 4.days.ago,
        source: "Reuters",
        url: "https://www.reuters.com/companies/TSLA.O/"
      }
    ]
  }
]

news_data.each do |stock_news|
  stock = Stock.find_by(symbol: stock_news[:stock_symbol])
  next unless stock

  stock_news[:articles].each do |article|
    news = News.find_or_create_by!(
      stock: stock,
      title: article[:title]
    ) do |n|
      n.content = article[:content]
      n.published_at = article[:published_at]
      n.source = article[:source]
      n.url = article[:url]
    end
    puts "  📰 Created news: #{news.title[0..50]}..."
  end
end

# Create price history for stocks (last 30 days)
puts "\n📈 Creating price history..."
stocks_data.each do |stock_data|
  stock = Stock.find_by(symbol: stock_data[:symbol])
  next unless stock
  
  base_price = stock_data[:price]
  
  30.times do |i|
    # Generate realistic price variations (+/- 5%)
    variation = rand(-5.0..5.0) / 100.0
    price_for_day = (base_price * (1 + variation)).round(2)
    
    PricePoint.create!(
      stock: stock,
      price: price_for_day,
      recorded_at: (30 - i).days.ago
    )
  end
  puts "  📊 Created 30-day price history for #{stock.symbol}"
end

puts "\n🎉 Seed data created successfully!"
puts "\n📊 Summary:"
puts "  - Companies: #{Company.count}"
puts "  - Users: #{User.count}"
puts "  - Stocks: #{Stock.count}"
puts "  - News Articles: #{News.count}"
puts "  - Price Points: #{PricePoint.count}"
puts "\n🔑 Login credentials:"
puts "  Admin - Email: admin@example.com, Password: password"
puts "  Trader - Email: trader@example.com, Password: password"
