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

## Snapshot
![WhatsApp Image 2025-05-25 at 10 45 45 PM (1)](https://github.com/user-attachments/assets/e540677a-2d00-4a77-aa7b-d87f0a5f0b64)

![WhatsApp Image 2025-05-25 at 10 45 45 PM (2)](https://github.com/user-attachments/assets/92421ec0-7491-4420-9f00-fa8b7be14c15)

![WhatsApp Image 2025-05-25 at 10 45 45 PM](https://github.com/user-attachments/assets/e5c9a00d-9950-469b-9757-82922a3d38b8)


