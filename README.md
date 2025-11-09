# E-Shop - AI-Powered E-commerce Platform

A modern, full-stack e-commerce application built with FastAPI, React, and PostgreSQL, featuring an AI-powered shopping assistant and beautiful, responsive UI.

## 🚀 Features

### Core Features
- **User Authentication & Authorization**
  - Email/password registration and login
  - Google OAuth integration
  - JWT-based authentication
  - Protected routes

- **Product Management**
  - Browse products by category
  - Advanced search and filtering
  - Product ratings and reviews
  - Image gallery with multiple photos
  - Stock management

- **Shopping Experience**
  - Add to cart functionality
  - Persistent cart across sessions
  - Secure checkout process
  - Order tracking and history

- **AI-Powered Assistant**
  - Real-time chat with AI shopping assistant
  - Product recommendations based on user queries
  - Context-aware responses
  - Session-based conversation history

- **Payment Integration**
  - Stripe payment processing
  - Multiple payment methods
  - Secure transaction handling
  - Order confirmation

- **File Management**
  - AWS S3 integration for product images
  - Multiple file upload support
  - Image optimization and resizing

### Technical Features
- **Responsive Design**
  - Mobile-first approach
  - Beautiful animations with Framer Motion
  - Dark/light theme support
  - Accessibility compliant

- **Performance Optimized**
  - Lazy loading components
  - Image optimization
  - Efficient state management
  - Caching strategies

- **Security**
  - HTTPS enforcement
  - Input validation and sanitization
  - SQL injection prevention
  - XSS protection

## 🏗️ Architecture

### Backend (FastAPI + Python 3.12)
- **Framework**: FastAPI with Uvicorn
- **Database**: PostgreSQL 16 with SQLAlchemy ORM
- **Authentication**: JWT tokens with Google OAuth
- **File Storage**: AWS S3
- **AI Integration**: OpenAI GPT-3.5-turbo
- **Payment**: Stripe API
- **Caching**: Redis (optional)

### Frontend (React + TypeScript)
- **Framework**: React 18 with TypeScript
- **Styling**: Tailwind CSS with custom components
- **State Management**: React Query + Context API
- **Routing**: React Router v6
- **Animations**: Framer Motion
- **UI Components**: Custom components with Headless UI
- **HTTP Client**: Axios with interceptors

### Database (PostgreSQL)
- **Version**: PostgreSQL 16 Alpine
- **Features**: JSON support, UUID primary keys
- **Optimization**: Indexes, triggers, constraints

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Web Server**: Nginx (production frontend)
- **Process Management**: Uvicorn (backend)
- **Health Checks**: Built-in health endpoints

## 📁 Project Structure

```
ecommerce-app/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── models/         # Database models
│   │   ├── schemas/        # Pydantic schemas
│   │   ├── services/       # Business logic
│   │   └── config.py       # Configuration
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/               # React frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── pages/         # Page components
│   │   ├── contexts/      # React contexts
│   │   ├── lib/           # Utilities and API
│   │   └── types/         # TypeScript types
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── database/
│   └── init.sql           # Database initialization
├── docker-compose.yml     # Container orchestration
└── README.md
```

## 🛠️ Installation & Setup

### Prerequisites
- Docker and Docker Compose
- Git

### 1. Clone the Repository
```bash
git clone <repository-url>
cd ecommerce-app
```

### 2. Environment Configuration

Create environment files for configuration:

**Backend (.env):**
```env
DATABASE_URL=postgresql://ecommerce_user:ecommerce_password@database:5432/ecommerce_db
SECRET_KEY=your-secret-key-change-in-production
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_BUCKET_NAME=your-s3-bucket-name
OPENAI_API_KEY=your-openai-api-key
STRIPE_SECRET_KEY=your-stripe-secret-key
```

**Frontend (.env):**
```env
REACT_APP_API_URL=http://localhost:8000
REACT_APP_STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key
```

### 3. Start the Application
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 4. Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: localhost:5432

## 🔧 Development

### Backend Development
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development
```bash
cd frontend
npm install
npm start
```

### Database Management
```bash
# Connect to database
docker-compose exec database psql -U ecommerce_user -d ecommerce_db

# Run migrations (if using Alembic)
docker-compose exec backend alembic upgrade head
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest
```

### Frontend Tests
```bash
cd frontend
npm test
```

### Integration Tests
```bash
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

## 🚀 Deployment

### Docker Compose (Production)
```bash
# Build and start production containers
docker-compose -f docker-compose.prod.yml up -d

# Scale services
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

### Kubernetes Deployment
```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods
kubectl get services
```

## 📊 API Documentation

### Authentication Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/google` - Google OAuth
- `GET /auth/me` - Get current user

### Product Endpoints
- `GET /products/` - List products
- `GET /products/{id}` - Get product details
- `GET /products/categories/` - List categories
- `GET /products/search/` - Search products

### Cart Endpoints
- `GET /cart/` - Get cart items
- `POST /cart/` - Add to cart
- `PUT /cart/{id}` - Update cart item
- `DELETE /cart/{id}` - Remove from cart

### Order Endpoints
- `GET /orders/` - List orders
- `POST /orders/` - Create order
- `POST /orders/{id}/payment-intent` - Create payment intent
- `POST /orders/{id}/confirm-payment` - Confirm payment

### Chat Endpoints
- `POST /chat/` - Send message to AI
- `GET /chat/history/{session_id}` - Get chat history
- `WebSocket /chat/ws/{user_id}` - Real-time chat

## 🔒 Security Considerations

- All passwords are hashed using bcrypt
- JWT tokens have expiration times
- CORS is properly configured
- Input validation on all endpoints
- SQL injection prevention with SQLAlchemy
- XSS protection with proper escaping

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support, email support@eshop.com or join our Slack channel.

## 🎯 Roadmap

- [ ] Mobile app (React Native)
- [ ] Advanced analytics dashboard
- [ ] Multi-language support
- [ ] Advanced recommendation engine
- [ ] Social login (Facebook, Twitter)
- [ ] Advanced inventory management
- [ ] Multi-vendor support
- [ ] Advanced reporting
- [ ] Email marketing integration
- [ ] Advanced search with Elasticsearch

---

Built with ❤️ using FastAPI, React, and modern web technologies.

trigger
