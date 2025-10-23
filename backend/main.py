from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from app.config import settings
from app.api import auth, products, cart, chat, orders, upload
import uvicorn

# Create FastAPI app
app = FastAPI(
    title="E-commerce API",
    description="A modern e-commerce platform with AI-powered shopping assistant",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add trusted host middleware
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["*"]  # In production, specify exact hosts
)

# Include routers
app.include_router(auth.router)
app.include_router(products.router)
app.include_router(cart.router)
app.include_router(chat.router)
app.include_router(orders.router)
app.include_router(upload.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to E-commerce API",
        "version": "1.0.0",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "message": "API is running"
    }

@app.get("/api/status")
async def api_status():
    """API status endpoint"""
    return {
        "status": "online",
        "version": "1.0.0",
        "features": [
            "User Authentication",
            "Google OAuth",
            "Product Management",
            "Shopping Cart",
            "AI Chat Assistant",
            "Order Management",
            "Payment Processing",
            "File Upload (S3)"
        ]
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )

