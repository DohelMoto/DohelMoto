-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(255),
    avatar_url TEXT,
    is_google_user BOOLEAN DEFAULT FALSE,
    google_id VARCHAR(255) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    discount_price DECIMAL(10,2),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    image_urls TEXT[] DEFAULT '{}',
    stock_quantity INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    sku VARCHAR(100) UNIQUE,
    brand VARCHAR(100),
    part_number VARCHAR(100),
    compatibility JSONB,
    weight DECIMAL(8,2),
    dimensions JSONB,
    warranty VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    shipping_address JSONB,
    billing_address JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create chat_messages table for AI chat
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_from_ai BOOLEAN DEFAULT FALSE,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_is_featured ON products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);

-- Insert admin user (password: admin123 - CHANGE IN PRODUCTION!)
-- Password hash generated with bcrypt for 'admin123'
INSERT INTO users (email, username, password_hash, full_name, role, is_active, is_verified) VALUES
('admin@dohelmoto.com', 'admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5aeJFcA5yw.yS', 'Admin User', 'admin', true, true)
ON CONFLICT (email) DO NOTHING;

-- Insert sample categories for off-road parts
INSERT INTO categories (name, description, image_url) VALUES
('UTV Parts', 'Parts and accessories for UTV vehicles like Maverick X3, RZR', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'),
('Chassis & Suspension', 'A-Arms, shocks, sway bars and suspension components', 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'),
('Wheels & Tires', 'Off-road wheels and tires for extreme terrain', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'),
('Lights & Switches', 'LED lights, light bars, and electrical switches', 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'),
('Winches', 'Heavy-duty winches and recovery equipment', 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'),
('Safety & Helmets', 'Helmets, HANS devices, and safety equipment', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'),
('Radio & Intercom', 'Communication systems for off-road vehicles', 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'),
('ATV Parts', 'Parts and accessories for ATV vehicles', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400')
ON CONFLICT (name) DO NOTHING;

-- Insert sample products for off-road parts
INSERT INTO products (name, description, price, discount_price, category_id, sku, brand, part_number, compatibility, stock_quantity, is_featured, rating, review_count, image_urls, weight, warranty) 
SELECT 
    p.name,
    p.description,
    p.price,
    p.discount_price,
    c.id,
    p.sku,
    p.brand,
    p.part_number,
    p.compatibility::jsonb,
    p.stock_quantity,
    p.is_featured,
    p.rating,
    p.review_count,
    p.image_urls,
    p.weight,
    p.warranty
FROM (VALUES
    ('Assault Industries High-Clearance A-Arms', 'Heavy-duty boxed A-arms for Maverick X3 with increased ground clearance and reinforced construction', 1899.99, 1799.99, 'Chassis & Suspension', 'AI-HCAA-X3', 'Assault Industries', 'AI-100250', '{"vehicles": ["Maverick X3 64\"", "Maverick X3 72\"", "Maverick X3 MAX"]}', 15, true, 4.9, 45, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 25.5, '1 Year'),
    ('SuperATV 32" Off-Road Tires', 'All-terrain 32-inch tires with aggressive 8-ply tread pattern for maximum traction', 899.99, NULL, 'Wheels & Tires', 'SATV-T32-AT', 'SuperATV', 'SATV-TR-1232', '{"vehicles": ["Maverick X3", "RZR XP 1000", "RZR Pro XP", "Universal"]}', 20, true, 4.8, 67, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 18.5, '1 Year'),
    ('Hess Motorsports Steering Rack Support', 'Reinforced steering rack brace for Maverick X3 to eliminate bump steer', 299.99, NULL, 'Chassis & Suspension', 'HMS-SRS-X3', 'Hess Motorsports', 'HMS-01234', '{"vehicles": ["Maverick X3 64\"", "Maverick X3 72\""]}', 30, false, 4.7, 89, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 3.2, '1 Year'),
    ('Baja Designs 50" LED Light Bar', 'High-output 50-inch LED light bar with combo beam pattern - 26,350 lumens', 1299.99, 1199.99, 'Lights & Switches', 'BD-LB50-C', 'Baja Designs', 'BD-45-7850', '{"vehicles": ["Universal fit"]}', 12, true, 5.0, 123, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 8.7, 'Limited Lifetime'),
    ('Warn VRX 4500 Winch', 'Synthetic rope winch with 4500 lb capacity and wireless remote', 749.99, NULL, 'Winches', 'WARN-VRX45', 'Warn', 'WARN-101045', '{"vehicles": ["Universal fit - UTV/ATV"]}', 8, true, 4.8, 156, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 15.8, 'Limited Lifetime'),
    ('Bell MX-9 Adventure Helmet', 'DOT approved off-road helmet with MIPS technology and adjustable visor', 399.99, 349.99, 'Safety & Helmets', 'BELL-MX9-ADV', 'Bell', 'BELL-7091826', '{"vehicles": ["Universal fit"]}', 25, false, 4.6, 234, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 1.6, '5 Years'),
    ('Rugged Radio M1 Intercom System', 'Two-place intercom with VOX, music input and waterproof design', 499.99, NULL, 'Radio & Intercom', 'RR-M1-2P', 'Rugged Radio', 'RR-M12P', '{"vehicles": ["Universal fit - UTV"]}', 18, true, 4.9, 78, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 1.2, '2 Years'),
    ('Shock Therapy Bump Stop Kit', 'Heavy-duty bump stop kit for Maverick X3 with extended travel', 159.99, NULL, 'Chassis & Suspension', 'ST-BSK-X3', 'Shock Therapy', 'ST-99456', '{"vehicles": ["Maverick X3"]}', 40, false, 4.7, 52, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 2.1, '1 Year'),
    ('Pro Armor Nerf Bars', 'Heavy-duty aluminum nerf bars with integrated foot pegs for Maverick X3', 599.99, 549.99, 'UTV Parts', 'PA-NB-X3', 'Pro Armor', 'PA-456789', '{"vehicles": ["Maverick X3 64\"", "Maverick X3 72\""]}', 14, true, 4.8, 93, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 18.0, '1 Year'),
    ('Rhino 2.0 Axles', 'Heavy-duty chromoly axles for Maverick X3 with 33" tires', 899.99, 849.99, 'UTV Parts', 'RHI-AXL-X3', 'Rhino', 'RHI-RHINO20', '{"vehicles": ["Maverick X3 72\""]}', 10, true, 4.9, 67, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 12.5, '18 Months'),
    ('SuperATV Portal Gear Lift', '6-inch portal gear lift for extreme ground clearance on RZR', 3499.99, NULL, 'Chassis & Suspension', 'SATV-PG6-RZR', 'SuperATV', 'SATV-PG-8899', '{"vehicles": ["RZR XP 1000", "RZR XP Turbo"]}', 4, true, 5.0, 28, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 45.0, '1 Year'),
    ('GBoost Turbo Kit', 'Complete turbo kit for Maverick X3 172hp - adds 50+ hp', 6999.99, NULL, 'UTV Parts', 'GB-TK-X3', 'GBoost', 'GB-172TK', '{"vehicles": ["Maverick X3 Turbo RR"]}', 3, true, 4.8, 15, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 28.0, '1 Year'),
    ('Kicker 6.5" Marine Speakers', 'Water-resistant 6.5-inch speakers for UTV - 150W peak', 249.99, 229.99, 'Radio & Intercom', 'KK-MS65', 'Kicker', 'KK-43KM654L', '{"vehicles": ["Universal fit"]}', 35, false, 4.6, 145, ARRAY['https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'], 3.5, '2 Years'),
    ('PRP Seats - GT/SE Suspension', 'Comfortable suspension seats with 5-point harness for UTV', 899.99, 849.99, 'UTV Parts', 'PRP-GTSE', 'PRP Seats', 'PRP-B1601', '{"vehicles": ["Universal fit - UTV"]}', 12, true, 4.9, 187, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 16.0, '5 Years'),
    ('Tusk Terrabite Tires 29"', '8-ply radial tires for ATV with excellent traction', 599.99, NULL, 'Wheels & Tires', 'TUSK-TB29', 'Tusk', 'TUSK-1441560003', '{"vehicles": ["ATV - Universal fit"]}', 22, false, 4.5, 98, ARRAY['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], 15.0, '1 Year')
) AS p(name, description, price, discount_price, category_name, sku, brand, part_number, compatibility, stock_quantity, is_featured, rating, review_count, image_urls, weight, warranty)
JOIN categories c ON c.name = p.category_name;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON cart_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
