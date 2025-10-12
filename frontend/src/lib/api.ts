import axios, { AxiosResponse } from 'axios';
import { 
  User, 
  Product, 
  Category, 
  CartItem, 
  Order, 
  ChatMessage,
  LoginCredentials,
  RegisterCredentials,
  GoogleAuthResponse,
  PaymentIntent,
  FileUpload,
  Address
} from '../types';

// Always use relative /api path - nginx will proxy to backend
const API_BASE_URL = '/api';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (credentials: LoginCredentials): Promise<AxiosResponse<{ access_token: string; token_type: string }>> =>
    api.post('/auth/login', credentials),
  
  register: (credentials: RegisterCredentials): Promise<AxiosResponse<User>> =>
    api.post('/auth/register', credentials),
  
  googleAuth: (token: string): Promise<AxiosResponse<{ access_token: string; token_type: string }>> =>
    api.post('/auth/google', { token }),
  
  getMe: (): Promise<AxiosResponse<User>> =>
    api.get('/auth/me'),
};

// Products API
export const productsAPI = {
  getProducts: (params?: {
    skip?: number;
    limit?: number;
    category_id?: string;
    search?: string;
    featured_only?: boolean;
  }): Promise<AxiosResponse<Product[]>> =>
    api.get('/products/', { params }),
  
  getProduct: (id: string): Promise<AxiosResponse<Product>> =>
    api.get(`/products/${id}`),
  
  getCategories: (): Promise<AxiosResponse<Category[]>> =>
    api.get('/products/categories/'),
  
  getProductsByCategory: (categoryId: string, params?: {
    skip?: number;
    limit?: number;
  }): Promise<AxiosResponse<Product[]>> =>
    api.get(`/products/category/${categoryId}`, { params }),
  
  searchProducts: (query: string, params?: {
    skip?: number;
    limit?: number;
  }): Promise<AxiosResponse<Product[]>> =>
    api.get('/products/search/', { params: { q: query, ...params } }),
  
  getFeaturedProducts: (limit?: number): Promise<AxiosResponse<Product[]>> =>
    api.get('/products/featured/', { params: { limit } }),
};

// Cart API
export const cartAPI = {
  getCartItems: (): Promise<AxiosResponse<CartItem[]>> =>
    api.get('/cart/'),
  
  addToCart: (productId: string, quantity: number): Promise<AxiosResponse<CartItem>> =>
    api.post('/cart/', { product_id: productId, quantity }),
  
  updateCartItem: (cartItemId: string, quantity: number): Promise<AxiosResponse<CartItem>> =>
    api.put(`/cart/${cartItemId}`, { quantity }),
  
  removeFromCart: (cartItemId: string): Promise<AxiosResponse<{ message: string }>> =>
    api.delete(`/cart/${cartItemId}`),
  
  clearCart: (): Promise<AxiosResponse<{ message: string }>> =>
    api.delete('/cart/'),
  
  getCartCount: (): Promise<AxiosResponse<{ count: number }>> =>
    api.get('/cart/count'),
};

// Orders API
export const ordersAPI = {
  getOrders: (): Promise<AxiosResponse<Order[]>> =>
    api.get('/orders/'),
  
  getOrder: (id: string): Promise<AxiosResponse<Order>> =>
    api.get(`/orders/${id}`),
  
  createOrder: (orderData: {
    shipping_address: Address;
    billing_address: Address;
    payment_method: string;
  }): Promise<AxiosResponse<Order>> =>
    api.post('/orders/', orderData),
  
  createPaymentIntent: (orderId: string, amount: number): Promise<AxiosResponse<PaymentIntent>> =>
    api.post(`/orders/${orderId}/payment-intent`, { amount }),
  
  confirmPayment: (orderId: string, paymentIntentId: string): Promise<AxiosResponse<{ message: string; order_status: string }>> =>
    api.post(`/orders/${orderId}/confirm-payment`, { payment_intent_id: paymentIntentId }),
  
  cancelOrder: (orderId: string): Promise<AxiosResponse<{ message: string }>> =>
    api.post(`/orders/${orderId}/cancel`),
};

// Chat API
export const chatAPI = {
  sendMessage: (message: string, sessionId?: string): Promise<AxiosResponse<ChatMessage>> =>
    api.post('/chat/', { message, session_id: sessionId }),
  
  getChatHistory: (sessionId: string, params?: {
    skip?: number;
    limit?: number;
  }): Promise<AxiosResponse<ChatMessage[]>> =>
    api.get(`/chat/history/${sessionId}`, { params }),
  
  getChatSessions: (): Promise<AxiosResponse<string[]>> =>
    api.get('/chat/sessions'),
  
  deleteChatSession: (sessionId: string): Promise<AxiosResponse<{ message: string }>> =>
    api.delete(`/chat/session/${sessionId}`),
};

// Upload API
export const uploadAPI = {
  uploadSingleFile: (file: File): Promise<AxiosResponse<FileUpload>> => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post('/upload/single', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },
  
  uploadMultipleFiles: (files: File[]): Promise<AxiosResponse<FileUpload[]>> => {
    const formData = new FormData();
    files.forEach(file => formData.append('files', file));
    return api.post('/upload/multiple', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },
  
  deleteFile: (fileUrl: string): Promise<AxiosResponse<{ message: string }>> =>
    api.delete('/upload/', { params: { file_url: fileUrl } }),
};

export default api;

