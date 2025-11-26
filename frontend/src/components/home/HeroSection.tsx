import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowRight, Star, Truck, Shield, Headphones } from 'lucide-react';

const HeroSection: React.FC = () => {
  return (
    <section className="relative bg-gradient-to-br from-primary-600 via-primary-700 to-accent-600 overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 bg-black opacity-10"></div>
      <div className="absolute inset-0" style={{
        backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Ccircle cx='30' cy='30' r='2'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
      }}></div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 lg:py-32">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Content */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="text-white"
          >
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.8 }}
              className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6"
            >
              Shop with{' '}
              <span className="text-yellow-300">AI Power</span>
            </motion.h1>
            
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4, duration: 0.8 }}
              className="text-xl md:text-2xl text-primary-100 mb-8 leading-relaxed"
            >
              Discover amazing products with our intelligent shopping assistant. 
              Get personalized recommendations and find exactly what you need.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6, duration: 0.8 }}
              className="flex flex-col sm:flex-row gap-4 mb-12"
            >
              <Link
                to="/shop"
                className="btn bg-white text-primary-600 hover:bg-gray-100 btn-lg px-8 inline-flex items-center justify-center group"
              >
                Start Shopping
                <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
              </Link>
              <Link
                to="/register"
                className="btn border-2 border-white text-white hover:bg-white hover:text-primary-600 btn-lg px-8"
              >
                Create Account
              </Link>
            </motion.div>

            {/* Features */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8, duration: 0.8 }}
              className="grid grid-cols-1 sm:grid-cols-3 gap-6"
            >
              <div className="flex items-center space-x-3">
                <div className="h-10 w-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                  <Truck className="h-5 w-5 text-white" />
                </div>
                <div>
                  <p className="font-semibold text-sm">Free Shipping</p>
                  <p className="text-xs text-primary-200">On orders over $50</p>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="h-10 w-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                  <Shield className="h-5 w-5 text-white" />
                </div>
                <div>
                  <p className="font-semibold text-sm">Secure Payment</p>
                  <p className="text-xs text-primary-200">100% protected</p>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="h-10 w-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                  <Headphones className="h-5 w-5 text-white" />
                </div>
                <div>
                  <p className="font-semibold text-sm">24/7 Support</p>
                  <p className="text-xs text-primary-200">Always here to help</p>
                </div>
              </div>
            </motion.div>
          </motion.div>

          {/* Visual Element */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4, duration: 0.8 }}
            className="relative"
          >
            <div className="relative">
              {/* Main Card */}
              <div className="bg-white rounded-2xl shadow-strong p-8 transform rotate-3 hover:rotate-0 transition-transform duration-500">
                <div className="space-y-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="h-12 w-12 bg-primary-100 rounded-xl flex items-center justify-center">
                        <Star className="h-6 w-6 text-primary-600" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-900">AI Assistant</h3>
                        <p className="text-sm text-gray-500">Online now</p>
                      </div>
                    </div>
                    <div className="h-3 w-3 bg-green-400 rounded-full animate-pulse"></div>
                  </div>
                  
                  <div className="space-y-3">
                    <div className="bg-gray-50 rounded-lg p-3">
                      <p className="text-sm text-gray-700">
                        Hi! I can help you find the perfect products. What are you looking for today?
                      </p>
                    </div>
                    
                    <div className="bg-primary-50 rounded-lg p-3 ml-8">
                      <p className="text-sm text-primary-700">
                        I'm interested in wireless headphones under $200
                      </p>
                    </div>
                    
                    <div className="bg-gray-50 rounded-lg p-3">
                      <p className="text-sm text-gray-700">
                        Great! I found 3 excellent options for you. Would you like to see them?
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex space-x-2">
                    <button className="flex-1 bg-primary-600 text-white py-2 px-4 rounded-lg text-sm font-medium hover:bg-primary-700 transition-colors">
                      View Products
                    </button>
                    <button className="bg-gray-100 text-gray-700 py-2 px-4 rounded-lg text-sm font-medium hover:bg-gray-200 transition-colors">
                      Ask More
                    </button>
                  </div>
                </div>
              </div>

              {/* Floating Elements */}
              <motion.div
                animate={{ y: [-10, 10, -10] }}
                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                className="absolute -top-4 -right-4 bg-yellow-400 text-yellow-900 px-3 py-1 rounded-full text-xs font-semibold"
              >
                AI Powered
              </motion.div>
              
              <motion.div
                animate={{ y: [10, -10, 10] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                className="absolute -bottom-4 -left-4 bg-green-400 text-green-900 px-3 py-1 rounded-full text-xs font-semibold"
              >
                Instant Help
              </motion.div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;

