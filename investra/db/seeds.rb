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

# Create news articles for stocks with real recent URLs
news_data = [
  {
    stock_symbol: "AAPL",
    articles: [
      {
        title: "Apple Unveils New iPhone 16 with Advanced AI Features",
        content: "Apple Inc. announced the iPhone 16 lineup today, featuring groundbreaking AI capabilities powered by the new A18 chip. The devices include improved camera systems, new photographic styles, and extended battery life. The Pro models feature titanium design and the most powerful iPhone chips ever.",
        published_at: 1.day.ago,
        source: "TechCrunch",
        url: "https://techcrunch.com/tag/apple/"
      },
      {
        title: "Apple Reports Record Q4 Earnings, Beats Wall Street Expectations",
        content: "Apple Inc. reported its fourth quarter financial results, beating analyst expectations with revenue of $89.5 billion and earnings per share of $1.46. Services revenue hit an all-time high, driven by the App Store, iCloud, and Apple Music.",
        published_at: 3.days.ago,
        source: "Reuters",
        url: "https://www.reuters.com/technology/apple/"
      },
      {
        title: "Apple Vision Pro Gains Momentum in Enterprise Markets",
        content: "The Apple Vision Pro is gaining significant traction in enterprise markets, with Fortune 500 companies adopting the spatial computing platform for immersive training, virtual collaboration, and 3D design workflows. Major retailers and healthcare providers lead adoption.",
        published_at: 5.days.ago,
        source: "Bloomberg",
        url: "https://www.bloomberg.com/quote/AAPL:US"
      },
      {
        title: "Apple Invests Billions in AI Research and Development",
        content: "Apple is ramping up its AI investments, pouring billions into developing on-device AI capabilities. The company's focus on privacy-first AI distinguishes it from competitors, with new features powered by Apple Intelligence arriving across all devices.",
        published_at: 8.days.ago,
        source: "The Verge",
        url: "https://www.theverge.com/apple"
      }
    ]
  },
  {
    stock_symbol: "GOOGL",
    articles: [
      {
        title: "Google Gemini 2.0 Launches with Multimodal AI Capabilities",
        content: "Alphabet's Google unveiled Gemini 2.0, the next generation of its AI model with enhanced multimodal capabilities. The model can seamlessly process text, images, audio, and video, positioning Google as a leader in the AI race against OpenAI and Microsoft.",
        published_at: 1.day.ago,
        source: "The Verge",
        url: "https://www.theverge.com/google"
      },
      {
        title: "Alphabet Expands Cloud Infrastructure with $15B Investment",
        content: "Alphabet Inc. announced plans to invest $15 billion in data centers and cloud infrastructure across the United States and Europe. The expansion aims to support growing AI workloads and Google Cloud's enterprise customers.",
        published_at: 2.days.ago,
        source: "CNBC",
        url: "https://www.cnbc.com/quotes/GOOGL"
      },
      {
        title: "YouTube Introduces AI-Powered Content Creation Tools",
        content: "YouTube, owned by Alphabet, launched new AI tools for content creators, including automated video editing, AI-generated thumbnails, and smart caption generation. The platform aims to empower creators with professional-grade AI assistance.",
        published_at: 4.days.ago,
        source: "TechCrunch",
        url: "https://techcrunch.com/tag/google/"
      },
      {
        title: "Google Search Market Share Remains Dominant Despite AI Challengers",
        content: "Despite the rise of AI-powered search alternatives, Google maintains over 90% global search market share. The company's integration of AI into traditional search has helped it retain its competitive edge.",
        published_at: 6.days.ago,
        source: "Bloomberg",
        url: "https://www.bloomberg.com/quote/GOOGL:US"
      }
    ]
  },
  {
    stock_symbol: "MSFT",
    articles: [
      {
        title: "Microsoft Azure Revenue Surges 33% Driven by AI Demand",
        content: "Microsoft Corporation reported stellar Azure cloud growth of 33% year-over-year, primarily driven by enterprise demand for AI services. The company's partnership with OpenAI continues to drive significant revenue growth across its cloud platform.",
        published_at: 1.day.ago,
        source: "Reuters",
        url: "https://www.reuters.com/technology/microsoft/"
      },
      {
        title: "Microsoft Copilot Now Available Across All Office Applications",
        content: "Microsoft announced the full rollout of Copilot AI assistant across all Office 365 applications. The AI-powered tool helps users with document creation, data analysis, and email management, transforming workplace productivity.",
        published_at: 2.days.ago,
        source: "TechCrunch",
        url: "https://techcrunch.com/tag/microsoft/"
      },
      {
        title: "Xbox Game Pass Hits 50 Million Subscribers",
        content: "Microsoft's Xbox Game Pass subscription service reached 50 million subscribers, cementing its position as the leading gaming subscription platform. The service offers access to hundreds of games, including day-one releases of Microsoft first-party titles.",
        published_at: 5.days.ago,
        source: "The Verge",
        url: "https://www.theverge.com/microsoft"
      },
      {
        title: "Microsoft Announces $60B Stock Buyback Program",
        content: "Microsoft Corporation's board approved a massive $60 billion stock buyback program and increased the quarterly dividend by 10%, signaling confidence in the company's financial strength and future growth prospects.",
        published_at: 7.days.ago,
        source: "Bloomberg",
        url: "https://www.bloomberg.com/quote/MSFT:US"
      }
    ]
  },
  {
    stock_symbol: "TSLA",
    articles: [
      {
        title: "Tesla Cybertruck Production Ramps to 1,000 Units Per Week",
        content: "Tesla Inc. announced that Cybertruck production has significantly increased, with the Austin Gigafactory now producing over 1,000 units per week. The all-electric pickup truck has received over 2 million pre-orders since its unveiling.",
        published_at: 1.day.ago,
        source: "Electrek",
        url: "https://electrek.co/guides/tesla/"
      },
      {
        title: "Tesla Full Self-Driving Beta Expands to All US Customers",
        content: "Tesla rolled out its Full Self-Driving (FSD) Beta software to all customers in the United States who purchased the feature. The latest version includes significant improvements in city driving and highway navigation capabilities.",
        published_at: 3.days.ago,
        source: "Reuters",
        url: "https://www.reuters.com/companies/TSLA.O/"
      },
      {
        title: "Tesla Opens Massive New Gigafactory in Mexico",
        content: "Tesla inaugurated its newest manufacturing facility in Monterrey, Mexico, which will produce next-generation affordable electric vehicles and battery packs. The facility is expected to create 10,000 jobs and produce 1 million vehicles annually.",
        published_at: 6.days.ago,
        source: "Bloomberg",
        url: "https://www.bloomberg.com/quote/TSLA:US"
      },
      {
        title: "Elon Musk Announces Tesla Semi Deliveries Accelerating",
        content: "Tesla CEO Elon Musk confirmed that production of the all-electric Tesla Semi is accelerating, with major companies like PepsiCo and Walmart receiving their first deliveries. The Semi promises up to 500 miles of range on a single charge.",
        published_at: 9.days.ago,
        source: "CNBC",
        url: "https://www.cnbc.com/quotes/TSLA"
      }
    ]
  },
  {
    stock_symbol: "AMZN",
    articles: [
      {
        title: "Amazon AWS Launches New AI Chip to Compete with Nvidia",
        content: "Amazon Web Services unveiled its latest custom AI chip, Graviton4, designed to offer superior price-performance for machine learning workloads. The chip aims to reduce reliance on Nvidia GPUs and lower costs for enterprise customers.",
        published_at: 1.day.ago,
        source: "TechCrunch",
        url: "https://techcrunch.com/tag/amazon/"
      },
      {
        title: "Amazon Prime Day Breaks All-Time Sales Records",
        content: "Amazon.com reported record-breaking sales during its annual Prime Day event, with total revenue exceeding $14 billion globally. Electronics, home goods, and fashion categories led the surge, driven by exclusive deals for Prime members.",
        published_at: 2.days.ago,
        source: "CNBC",
        url: "https://www.cnbc.com/quotes/AMZN"
      },
      {
        title: "Amazon Expands Same-Day Delivery to 90 More US Cities",
        content: "Amazon announced a major expansion of its same-day delivery service, now covering 90 additional U.S. cities. The company continues to invest heavily in logistics infrastructure to maintain its competitive edge in e-commerce.",
        published_at: 5.days.ago,
        source: "Reuters",
        url: "https://www.reuters.com/companies/AMZN.O/"
      },
      {
        title: "Amazon Invests $4B in AI Startup Anthropic",
        content: "Amazon completed a $4 billion investment in Anthropic, the AI safety company behind Claude AI. The partnership will integrate Claude across Amazon's services and make Anthropic's models available on AWS to enterprise customers.",
        published_at: 8.days.ago,
        source: "Bloomberg",
        url: "https://www.bloomberg.com/quote/AMZN:US"
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
