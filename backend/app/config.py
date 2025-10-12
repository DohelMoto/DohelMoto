from pydantic_settings import BaseSettings
from pydantic import ConfigDict, field_validator
from typing import Optional, Union


class Settings(BaseSettings):
    # Pydantic v2 configuration
    model_config = ConfigDict(
        env_file=".env",
        extra="ignore",  # Allow extra environment variables
        case_sensitive=False  # Allow both uppercase and lowercase env vars
    )
    
    # Database
    database_url: str = "postgresql://ecommerce_user:ecommerce_password@database:5432/ecommerce_db"
    
    # Security
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Google OAuth
    google_client_id: Optional[str] = None
    google_client_secret: Optional[str] = None
    
    # AWS S3
    aws_access_key_id: Optional[str] = None
    aws_secret_access_key: Optional[str] = None
    aws_bucket_name: Optional[str] = None
    aws_region: str = "us-east-1"
    
    # OpenAI
    openai_api_key: Optional[str] = None
    
    # Stripe
    stripe_secret_key: Optional[str] = None
    stripe_publishable_key: Optional[str] = None
    
    # CORS
    allowed_origins: Union[list[str], str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://frontend:80",
        "http://localhost:8080"
    ]
    
    @field_validator('allowed_origins', mode='before')
    @classmethod
    def parse_allowed_origins(cls, v):
        """Parse allowed_origins from string or list"""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(',')]
        return v
    
    # Redis
    redis_url: str = "redis://redis:6379"


settings = Settings()
if settings.openai_api_key:
    print(f"OpenAI API Key loaded: {settings.openai_api_key[:10]}...")
else:
    print("No OpenAI API key found in environment - AI features will be disabled")

