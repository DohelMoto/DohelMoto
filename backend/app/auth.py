from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
import bcrypt
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.config import settings
from app.database import get_db
from app.models import User
from app.schemas import TokenData
import google.auth.transport.requests
from google.oauth2 import id_token
import requests

# JWT token security
security = HTTPBearer()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def get_password_hash(password: str) -> str:
    """Hash a password"""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
    return encoded_jwt

def verify_token(token: str, credentials_exception):
    """Verify JWT token and return token data"""
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        token_data = TokenData(user_id=user_id)
    except JWTError:
        raise credentials_exception
    return token_data

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    token = credentials.credentials
    token_data = verify_token(token, credentials_exception)
    
    user = db.query(User).filter(User.id == token_data.user_id).first()
    if user is None:
        raise credentials_exception
    return user

def get_current_active_user(current_user: User = Depends(get_current_user)) -> User:
    """Get current active user"""
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
    """Authenticate user with email and password"""
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user

def verify_google_token(token: str) -> Optional[dict]:
    """Verify Google OAuth token and return user info"""
    try:
        if not settings.google_client_id:
            print("Google Client ID not configured")
            return None
            
        # Verify the token
        idinfo = id_token.verify_oauth2_token(
            token, 
            google.auth.transport.requests.Request(),
            settings.google_client_id
        )
        
        # Verify the issuer
        if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            raise ValueError('Wrong issuer.')
        
        return {
            'google_id': idinfo['sub'],
            'email': idinfo['email'],
            'name': idinfo.get('name', ''),
            'picture': idinfo.get('picture', '')
        }
    except ValueError as e:
        print(f"Google token verification failed: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error during Google token verification: {e}")
        return None

def create_or_get_google_user(db: Session, google_user_info: dict) -> User:
    """Create or get user from Google OAuth info"""
    user = db.query(User).filter(User.google_id == google_user_info['google_id']).first()
    
    if not user:
        # Check if user exists with same email
        user = db.query(User).filter(User.email == google_user_info['email']).first()
        if user:
            # Link Google account to existing user
            user.google_id = google_user_info['google_id']
            user.is_google_user = True
            user.avatar_url = google_user_info.get('picture')
            if not user.full_name:
                user.full_name = google_user_info.get('name')
        else:
            # Create new user
            user = User(
                email=google_user_info['email'],
                username=google_user_info['email'].split('@')[0],  # Use email prefix as username
                full_name=google_user_info.get('name'),
                avatar_url=google_user_info.get('picture'),
                google_id=google_user_info['google_id'],
                is_google_user=True,
                is_active=True,
                is_verified=True  # Google users are considered verified
            )
            db.add(user)
        
        db.commit()
        db.refresh(user)
    
    return user

def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
    """Get user by ID"""
    return db.query(User).filter(User.id == user_id).first()

