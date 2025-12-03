from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from decimal import Decimal
from uuid import UUID


# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(UserBase):
    id: UUID
    is_active: bool
    is_verified: bool
    is_google_user: bool
    role: str = "user"
    created_at: datetime
    
    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    username: Optional[str] = None
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None


# Auth Schemas
class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    user_id: Optional[str] = None


# Google OAuth Schemas
class GoogleAuthRequest(BaseModel):
    token: str


# Category Schemas
class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None


class CategoryCreate(CategoryBase):
    pass


class CategoryResponse(CategoryBase):
    id: UUID
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_active: Optional[bool] = None


# Product Schemas
class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: Decimal
    discount_price: Optional[Decimal] = None
    category_id: Optional[UUID] = None
    image_urls: List[str] = []
    stock_quantity: int = 0
    is_active: bool = True
    is_featured: bool = False
    sku: Optional[str] = None
    brand: Optional[str] = None
    part_number: Optional[str] = None
    compatibility: Optional[dict] = None  # Compatible vehicles/models
    weight: Optional[Decimal] = None
    dimensions: Optional[dict] = None  # {"length": 10, "width": 5, "height": 3}
    warranty: Optional[str] = None


class ProductCreate(ProductBase):
    pass


class ProductResponse(ProductBase):
    id: UUID
    rating: float
    review_count: int
    created_at: datetime
    updated_at: datetime
    category: Optional[CategoryResponse] = None
    
    class Config:
        from_attributes = True


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[Decimal] = None
    discount_price: Optional[Decimal] = None
    category_id: Optional[UUID] = None
    image_urls: Optional[List[str]] = None
    stock_quantity: Optional[int] = None
    is_active: Optional[bool] = None
    is_featured: Optional[bool] = None
    sku: Optional[str] = None
    brand: Optional[str] = None
    part_number: Optional[str] = None
    compatibility: Optional[dict] = None
    weight: Optional[Decimal] = None
    dimensions: Optional[dict] = None
    warranty: Optional[str] = None


# Cart Schemas
class CartItemBase(BaseModel):
    product_id: UUID
    quantity: int = 1


class CartItemCreate(CartItemBase):
    pass


class CartItemResponse(CartItemBase):
    id: UUID
    product: ProductResponse
    created_at: datetime
    
    class Config:
        from_attributes = True


class CartItemUpdate(BaseModel):
    quantity: int


# Order Schemas
class OrderBase(BaseModel):
    shipping_address: dict
    billing_address: dict
    payment_method: str


class OrderCreate(OrderBase):
    pass


class OrderItemResponse(BaseModel):
    id: UUID
    product_id: Optional[UUID]
    quantity: int
    price: Decimal
    product: Optional[ProductResponse] = None
    
    class Config:
        from_attributes = True


class OrderResponse(OrderBase):
    id: UUID
    user_id: Optional[UUID]
    total_amount: Decimal
    status: str
    payment_status: str
    created_at: datetime
    order_items: List[OrderItemResponse] = []
    
    class Config:
        from_attributes = True


# Chat Schemas
class ChatMessageBase(BaseModel):
    message: str
    session_id: Optional[str] = None


class ChatMessageCreate(ChatMessageBase):
    pass


class ChatMessageResponse(ChatMessageBase):
    id: UUID
    user_id: UUID
    is_from_ai: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# Review Schemas
class ReviewBase(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None


class ReviewCreate(ReviewBase):
    product_id: UUID


class ReviewResponse(ReviewBase):
    id: UUID
    user_id: UUID
    product_id: UUID
    is_verified_purchase: bool
    created_at: datetime
    user: UserResponse
    
    class Config:
        from_attributes = True


# Payment Schemas
class PaymentIntentCreate(BaseModel):
    amount: Decimal
    currency: str = "usd"
    order_id: UUID


class PaymentIntentResponse(BaseModel):
    client_secret: str
    payment_intent_id: str


# File Upload Schemas
class FileUploadResponse(BaseModel):
    url: str
    filename: str
    size: int

