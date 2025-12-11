# 📈 Investra – Stock Trading Analyzer

## 📌 Project Overview
Investra is a **multi-module Software-as-a-Service (SaaS) stock trading platform** built with Ruby on Rails.  
The platform is designed for **individual investors, associate traders, portfolio managers, and system administrators** to track trades, manage portfolios, and analyze market data with ease.  

This project was developed as part of **CS-UY 4513 – Software Engineering** under the guidance of **Professor Dr. DePasquale**.

Link to our deployed web app [here](https://investra-61e9499b805d.herokuapp.com/login)

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
- **User & Identity Management**  
  Secure authentication and role-based permissions for traders, associates, managers, and admins.

- **Trading & Portfolio Management**  
  Place buy/sell orders, track performance, and monitor portfolios.

- **Market Data Integration**  
  Real-time and historical stock data, financial reports, and AI/ML-powered predictions.

- **Associate Analytics**  
  Performance tracking, reporting, and dashboards for managers and system-wide analytics.
  
- **For detail feature setup**
  [Check here](./docs/investra_features.md)

---

## 🛠️ Tech Stack
- **Language:** Ruby  
- **Framework:** Ruby on Rails (latest stable version)  
- **Database:** MySQL  
- **Testing:** RSpec  

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

## ▶️ Local Run (Docker)
- See `investra/README.md` for Docker-based local startup instructions and dev/test admin login details.

## 📅 Course Information
- **Course:** CS-UY 4513 – Software Engineering  
- **Professor:** Dr. DePasquale  
- **Date:** September 27, 2025  

---
