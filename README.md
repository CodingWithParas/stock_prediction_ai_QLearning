# 📈 Stock AI App using Q-Learning in Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.0-blue?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.8+-yellow?logo=python)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Issues](https://img.shields.io/github/issues/yourusername/stock-ai-app)](https://github.com/yourusername/stock-ai-app/issues)
[![Stars](https://img.shields.io/github/stars/yourusername/stock-ai-app?style=social)](https://github.com/yourusername/stock-ai-app/stargazers)

A smart Flutter application that uses **Q-learning**, a reinforcement learning technique, to predict stock market behavior and assist users with intelligent trading suggestions.

---

## 🚀 Features

- 📊 Real-time stock data from Alpha Vantage or Yahoo Finance
- 🤖 Q-Learning-based AI for trading decision-making
- 📱 Cross-platform Flutter frontend (Android & iOS)
- 🌗 Light and dark theme support
- 🔍 Live symbol search and prediction display
- 📉 Graphs showing historical & predicted prices
- 🔁 Backend API with Flask or FastAPI

---

## 🧠 How Q-Learning Works in This App

- The agent observes the stock environment and takes actions: `Buy`, `Sell`, or `Hold`
- It receives rewards based on profit or loss
- Over time, the Q-table is updated to learn the best strategies for trading

---

## 📁 Project Structure

stock-ai-app/
├── lib/
│ ├── main.dart
│ ├── screens/
│ ├── widgets/
│ ├── services/
│ └── models/
├── backend/
│ ├── q_learning_agent.py
│ ├── data_fetcher.py
│ └── server.py
├── assets/
├── pubspec.yaml
└── README.md

yaml
Copy
Edit

---

## 🛠 Tech Stack

| Layer      | Tech Used                              |
|------------|----------------------------------------|
| Frontend   | Flutter, Dart, fl_chart, Provider/Bloc |
| Backend    | Python, FastAPI/Flask, Q-Learning      |
| Data       | Alpha Vantage, yfinance, pandas        |
| Deployment | Ngrok / Localhost                      |

---

## 🔧 Setup Instructions

### 1️⃣ Backend

```bash
cd backend/
pip install -r requirements.txt
python server.py

Optionally expose with ngrok if using on a device:
ngrok http 8000
# ScreenShort
![WhatsApp Image 2025-05-25 at 10 45 45 PM (2)](https://github.com/user-attachments/assets/0c06237f-7832-4778-aad7-2a7264a1d355)
![WhatsApp Image 2025-05-25 at 10 45 45 PM](https://github.com/user-attachments/assets/e3f19a98-0578-4080-b3bb-3b27456de37a)
![WhatsApp Image 2025-05-25 at 10 45 45 PM (1)](https://github.com/user-attachments/assets/923fc8e8-8c7f-4d02-a8c5-ea49c80594d0)
