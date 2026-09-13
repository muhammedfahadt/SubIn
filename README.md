# SubIn
Stop watching. Sub into the game.

SubIn is a geolocation-powered sports meetup platform that connects players to nearby games they can join right now — no team, no commitment, no more spectating.
🎯 The Problem
You want to play, but you don't have a team. You scroll past courts full of games, but you're stuck on the sidelines. SubIn fixes that. Find open games near you, request to join, and get on the field.

🔥 What It Does
Table
Feature	Description
🔍 Venue Discovery	Find sports grounds near you with maps, filters, and ratings
🎮 Event Hosting	Create games, set player limits, and manage join requests
👥 Player Matchmaking	Find nearby players by sport, skill level, and availability
🏆 Team Building	Form teams, recruit players, and manage rosters
💬 In-App Chat	Coordinate logistics with event and team chat
📍 Geolocation	PostGIS-powered nearby search with real-time distance
🔐 Secure Auth	JWT-based authentication with token refresh


## 🚀 Getting Started

### 1. Clone & Setup
```bash
git clone https://github.com/yourusername/subIn.git
cd subIn
```

### 2. Start Backend
```bash
# Using Docker (recommended)
docker-compose up -d

# Or manually
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### 3. Start Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome  # For web
# OR
flutter run            # For mobile emulator
```

### 4. Seed Sample Data
```bash
curl -X POST http://localhost:8000/venues/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "City Sports Complex",
    "address": "123 Sports Lane, Mumbai",
    "city": "Mumbai",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "sports": ["football", "cricket", "basketball"],
    "has_lights": true,
    "has_changing_room": true,
    "price_per_hour": 500
  }'
```

---

## 📱 Key Features Implemented

| Feature | Description | Status |
|---------|-------------|--------|
| 🔍 **Venue Discovery** | Find sports grounds with maps, filters, ratings | ✅ |
| 🎮 **Event Hosting** | Create games, set player limits, manage join requests |  |
| 👥 **Player Matchmaking** | Find nearby players by sport, skill level, availability |  |
| 🏆 **Team Building** | Form teams, recruit players, manage rosters |  |
| 💬 **In-App Coordination** | Event/team chat for logistics |  |
| 📍 **Geolocation** | PostGIS-powered nearby search with distance | ✅ |
| 🔐 **JWT Auth** | Secure login/register with token refresh |  |

---

## 🔮 Future Enhancements

- [ ] **Payment Integration** - Split costs for venue bookings
- [ ] **Elo Rating System** - Skill-based matchmaking
- [ ] **Push Notifications** - Real-time join requests & reminders
- [ ] **Venue Booking API** - Integrate with BookMyShow/Sports facilities
- [ ] **AI Matchmaking** - ML-based player compatibility scoring
- [ ] **Live Scoring** - Track match stats & leaderboards
- [ ] **Community Features** - Forums, challenges, achievements

---

## 📄 License

MIT License - Built with ❤️ for the sports community.
