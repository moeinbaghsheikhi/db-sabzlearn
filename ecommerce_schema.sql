-- E-Commerce Database | MySQL 8.0+
-- Boutique / Clothing Store
-- Review ENUM values and currency precision against application requirements before production.

CREATE DATABASE IF NOT EXISTS ecommerce_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

SET NAMES utf8mb4;
-- This script does not drop existing tables or delete existing data.


-- 1. Users and access control
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(100) NULL,
  last_name VARCHAR(100) NULL,
  mobile VARCHAR(30) NULL,
  password VARCHAR(255) NULL,
  status ENUM('pending','active','inactive','blocked') NOT NULL DEFAULT 'pending',
  mobile_verified_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_mobile (mobile)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE roles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permissions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_permissions_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_user (
  role_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (role_id, user_id),
  CONSTRAINT fk_role_user_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_role_user_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_permission (
  role_id INT UNSIGNED NOT NULL,
  permission_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (permission_id, role_id),
  CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Addresses
CREATE TABLE addresses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(100) NULL,
  recipient_name VARCHAR(200) NULL,
  mobile VARCHAR(30) NULL,
  province VARCHAR(100) NULL,
  city VARCHAR(100) NULL,
  postal_code VARCHAR(20) NULL,
  address TEXT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_addresses_user_id (user_id),
  CONSTRAINT fk_addresses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Catalog
CREATE TABLE categories (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_id INT UNSIGNED NULL,
  name VARCHAR(150) NULL,
  slug VARCHAR(180) NULL,
  description TEXT NULL,
  image VARCHAR(255) NULL,
  status ENUM('active','inactive','hidden') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug (slug),
  KEY idx_categories_parent_id (parent_id),
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE brands (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NULL,
  slug VARCHAR(180) NULL,
  description TEXT NULL,
  logo VARCHAR(255) NULL,
  status ENUM('active','inactive','hidden') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_brands_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  brand_id INT UNSIGNED NULL,
  name VARCHAR(200) NULL,
  slug VARCHAR(220) NULL,
  sku VARCHAR(100) NULL,
  description TEXT NULL,
  short_description TEXT NULL,
  type ENUM('simple','variable') NOT NULL DEFAULT 'simple',
  status ENUM('draft','active','inactive','out_of_stock','archived') NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_brand_id (brand_id),
  CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_categories (
  product_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, category_id),
  KEY idx_product_categories_category_id (category_id),
  CONSTRAINT fk_product_categories_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_categories_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_variants (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id INT UNSIGNED NOT NULL,
  sku VARCHAR(100) NULL,
  price DECIMAL(12,2) NULL,
  compare_price DECIMAL(12,2) NULL,
  cost_price DECIMAL(12,2) NULL,
  status ENUM('active','inactive','out_of_stock','discontinued') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_variants_sku (sku),
  KEY idx_product_variants_product_id (product_id),
  CONSTRAINT fk_product_variants_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_images (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id INT UNSIGNED NOT NULL,
  variant_id INT UNSIGNED NULL,
  image VARCHAR(255) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_images_product_id (product_id),
  KEY idx_product_images_variant_id (variant_id),
  CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_images_variant FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attributes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NULL,
  slug VARCHAR(180) NULL,
  type ENUM('text','number','select','color','size','boolean') NOT NULL DEFAULT 'select',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_attributes_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attribute_values (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  attribute_id INT UNSIGNED NOT NULL,
  value VARCHAR(150) NULL,
  slug VARCHAR(180) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attribute_values_attribute_id (attribute_id),
  KEY idx_attribute_values_slug (slug),
  CONSTRAINT fk_attribute_values_attribute FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_attributes (
  product_id INT UNSIGNED NOT NULL,
  attribute_id INT UNSIGNED NOT NULL,
  attribute_value_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, attribute_id, attribute_value_id),
  KEY idx_product_attributes_attribute_id (attribute_id),
  KEY idx_product_attributes_value_id (attribute_value_id),
  CONSTRAINT fk_product_attributes_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_attributes_attribute FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_attributes_value FOREIGN KEY (attribute_value_id) REFERENCES attribute_values(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_variant_values (
  product_variant_id INT UNSIGNED NOT NULL,
  attribute_value_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (product_variant_id, attribute_value_id),
  KEY idx_product_variant_values_value_id (attribute_value_id),
  CONSTRAINT fk_product_variant_values_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_variant_values_value FOREIGN KEY (attribute_value_id) REFERENCES attribute_values(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Inventory
CREATE TABLE warehouses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NULL,
  code VARCHAR(50) NULL,
  address TEXT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_warehouses_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventories (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  warehouse_id INT UNSIGNED NOT NULL,
  product_variant_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  reserved_quantity INT NOT NULL DEFAULT 0,
  low_stock_threshold INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inventories_warehouse_variant (warehouse_id, product_variant_id),
  KEY idx_inventories_variant_id (product_variant_id),
  CONSTRAINT fk_inventories_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inventories_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_transactions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  inventory_id INT UNSIGNED NOT NULL,
  type ENUM('stock_in','stock_out','sale','return','adjustment','reservation','reservation_release','transfer_in','transfer_out') NOT NULL,
  quantity INT NOT NULL,
  reference_type VARCHAR(100) NULL,
  reference_id INT UNSIGNED NULL,
  note TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_inventory_transactions_inventory_id (inventory_id),
  KEY idx_inventory_transactions_reference (reference_type, reference_id),
  CONSTRAINT fk_inventory_transactions_inventory FOREIGN KEY (inventory_id) REFERENCES inventories(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Cart and wishlist
CREATE TABLE carts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  status ENUM('active','converted','abandoned') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_carts_user_id (user_id),
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cart_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id INT UNSIGNED NOT NULL,
  product_variant_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_cart_items_cart_id (cart_id),
  KEY idx_cart_items_variant_id (product_variant_id),
  CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_cart_items_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wishlists (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NULL,
  user_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_wishlists_user_id (user_id),
  CONSTRAINT fk_wishlists_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wishlist_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  wishlist_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wishlist_items_wishlist_product (wishlist_id, product_id),
  KEY idx_wishlist_items_product_id (product_id),
  CONSTRAINT fk_wishlist_items_wishlist FOREIGN KEY (wishlist_id) REFERENCES wishlists(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_wishlist_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Orders
CREATE TABLE orders (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  address_id INT UNSIGNED NULL,
  order_number VARCHAR(100) NULL,
  status ENUM('pending','confirmed','processing','ready_to_ship','shipped','delivered','cancelled','returned','refunded') NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(12,2) NULL DEFAULT 0.00,
  discount_amount DECIMAL(12,2) NULL DEFAULT 0.00,
  shipping_amount DECIMAL(12,2) NULL DEFAULT 0.00,
  total_amount DECIMAL(12,2) NULL DEFAULT 0.00,
  customer_note TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_order_number (order_number),
  KEY idx_orders_user_id (user_id),
  KEY idx_orders_address_id (address_id),
  KEY idx_orders_status (status),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_orders_address FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id INT UNSIGNED NOT NULL,
  product_variant_id INT UNSIGNED NULL,
  product_name VARCHAR(200) NULL,
  variant_name VARCHAR(200) NULL,
  sku VARCHAR(100) NULL,
  quantity INT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NULL,
  total_price DECIMAL(12,2) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order_id (order_id),
  KEY idx_order_items_variant_id (product_variant_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_status_histories (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id INT UNSIGNED NOT NULL,
  status ENUM('pending','confirmed','processing','ready_to_ship','shipped','delivered','cancelled','returned','refunded') NOT NULL,
  note TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_status_histories_order_id (order_id),
  CONSTRAINT fk_order_status_histories_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Payments and wallet
CREATE TABLE payments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id INT UNSIGNED NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  method ENUM('online','wallet','cash_on_delivery','bank_transfer','other') NOT NULL DEFAULT 'online',
  status ENUM('pending','processing','paid','failed','cancelled','refunded','partially_refunded') NOT NULL DEFAULT 'pending',
  transaction_id VARCHAR(150) NULL,
  gateway VARCHAR(100) NULL,
  paid_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_payments_order_id (order_id),
  KEY idx_payments_status (status),
  KEY idx_payments_transaction_id (transaction_id),
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wallets (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status ENUM('active','frozen','closed') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wallets_user_id (user_id),
  CONSTRAINT fk_wallets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wallet_transactions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  wallet_id INT UNSIGNED NOT NULL,
  type ENUM('purchase','withdrawal','top_up','refund','gift','adjustment','transfer') NOT NULL,
  direction ENUM('credit','debit') NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  balance_before DECIMAL(12,2) NULL,
  balance_after DECIMAL(12,2) NULL,
  reference_type VARCHAR(100) NULL,
  reference_id INT UNSIGNED NULL,
  description TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_wallet_transactions_wallet_id (wallet_id),
  KEY idx_wallet_transactions_reference (reference_type, reference_id),
  CONSTRAINT fk_wallet_transactions_wallet FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Shipping
CREATE TABLE shipping_methods (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NULL,
  code VARCHAR(60) NULL,
  description TEXT NULL,
  base_cost DECIMAL(12,2) NULL DEFAULT 0.00,
  estimated_days INT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_shipping_methods_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id INT UNSIGNED NOT NULL,
  shipping_method_id INT UNSIGNED NULL,
  address_id INT UNSIGNED NULL,
  tracking_number VARCHAR(150) NULL,
  status ENUM('pending','processing','packed','shipped','in_transit','out_for_delivery','delivered','failed','returned','cancelled') NOT NULL DEFAULT 'pending',
  shipping_cost DECIMAL(12,2) NULL DEFAULT 0.00,
  shipped_at TIMESTAMP NULL DEFAULT NULL,
  delivered_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_shipments_order_id (order_id),
  KEY idx_shipments_method_id (shipping_method_id),
  KEY idx_shipments_address_id (address_id),
  KEY idx_shipments_tracking_number (tracking_number),
  CONSTRAINT fk_shipments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipments_method FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_shipments_address FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_status_histories (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  shipment_id INT UNSIGNED NOT NULL,
  status ENUM('pending','processing','packed','shipped','in_transit','out_for_delivery','delivered','failed','returned','cancelled') NOT NULL,
  note TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_shipment_status_histories_shipment_id (shipment_id),
  CONSTRAINT fk_shipment_status_histories_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Discounts and marketing
CREATE TABLE discount_campaigns (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(180) NULL,
  description TEXT NULL,
  type ENUM('percentage','fixed_amount','free_shipping','buy_x_get_y') NOT NULL DEFAULT 'percentage',
  status ENUM('draft','scheduled','active','paused','ended','cancelled') NOT NULL DEFAULT 'draft',
  starts_at TIMESTAMP NULL DEFAULT NULL,
  ends_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_discount_campaigns_status (status),
  KEY idx_discount_campaigns_dates (starts_at, ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discount_codes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  campaign_id INT UNSIGNED NULL,
  code VARCHAR(100) NULL,
  type ENUM('percentage','fixed_amount','free_shipping') NOT NULL DEFAULT 'percentage',
  value DECIMAL(12,2) NULL DEFAULT 0.00,
  min_order_amount DECIMAL(12,2) NULL DEFAULT 0.00,
  max_discount_amount DECIMAL(12,2) NULL,
  usage_limit INT NULL,
  usage_limit_per_user INT NULL,
  used_count INT NOT NULL DEFAULT 0,
  starts_at TIMESTAMP NULL DEFAULT NULL,
  ends_at TIMESTAMP NULL DEFAULT NULL,
  status ENUM('active','inactive','expired','exhausted') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_discount_codes_code (code),
  KEY idx_discount_codes_campaign_id (campaign_id),
  KEY idx_discount_codes_status (status),
  CONSTRAINT fk_discount_codes_campaign FOREIGN KEY (campaign_id) REFERENCES discount_campaigns(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discount_code_products (
  discount_code_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (discount_code_id, product_id),
  KEY idx_discount_code_products_product_id (product_id),
  CONSTRAINT fk_discount_code_products_code FOREIGN KEY (discount_code_id) REFERENCES discount_codes(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_discount_code_products_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discount_code_categories (
  discount_code_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (discount_code_id, category_id),
  KEY idx_discount_code_categories_category_id (category_id),
  CONSTRAINT fk_discount_code_categories_code FOREIGN KEY (discount_code_id) REFERENCES discount_codes(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_discount_code_categories_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discount_usages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  discount_code_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  order_id INT UNSIGNED NOT NULL,
  discount_amount DECIMAL(12,2) NULL DEFAULT 0.00,
  used_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_discount_usages_code_id (discount_code_id),
  KEY idx_discount_usages_user_id (user_id),
  KEY idx_discount_usages_order_id (order_id),
  CONSTRAINT fk_discount_usages_code FOREIGN KEY (discount_code_id) REFERENCES discount_codes(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_discount_usages_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_discount_usages_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Reviews and product interaction
CREATE TABLE product_reviews (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  order_item_id INT UNSIGNED NULL,
  rating INT NOT NULL,
  title VARCHAR(200) NULL,
  comment TEXT NULL,
  status ENUM('pending','approved','rejected','hidden') NOT NULL DEFAULT 'pending',
  is_verified_purchase BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_reviews_user_id (user_id),
  KEY idx_product_reviews_product_id (product_id),
  KEY idx_product_reviews_order_item_id (order_item_id),
  KEY idx_product_reviews_status (status),
  CONSTRAINT fk_product_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_reviews_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_reviews_order_item FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_review_images (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  review_id INT UNSIGNED NOT NULL,
  image VARCHAR(255) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_review_images_review_id (review_id),
  CONSTRAINT fk_product_review_images_review FOREIGN KEY (review_id) REFERENCES product_reviews(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_review_votes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  review_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  vote ENUM('helpful','not_helpful') NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_review_votes_review_user (review_id, user_id),
  KEY idx_product_review_votes_user_id (user_id),
  CONSTRAINT fk_product_review_votes_review FOREIGN KEY (review_id) REFERENCES product_reviews(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_review_votes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_questions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  question TEXT NULL,
  status ENUM('pending','approved','rejected','hidden') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_questions_user_id (user_id),
  KEY idx_product_questions_product_id (product_id),
  KEY idx_product_questions_status (status),
  CONSTRAINT fk_product_questions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_questions_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_answers (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  question_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  answer TEXT NULL,
  status ENUM('pending','approved','rejected','hidden') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_answers_question_id (question_id),
  KEY idx_product_answers_user_id (user_id),
  KEY idx_product_answers_status (status),
  CONSTRAINT fk_product_answers_question FOREIGN KEY (question_id) REFERENCES product_questions(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_answers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_views (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  product_id INT UNSIGNED NOT NULL,
  session_id VARCHAR(150) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_views_user_id (user_id),
  KEY idx_product_views_product_id (product_id),
  KEY idx_product_views_session_id (session_id),
  KEY idx_product_views_created_at (created_at),
  CONSTRAINT fk_product_views_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_product_views_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Note: DBML did not specify explicit nullability for most fields. Nullable fields are kept nullable,
-- while identifiers and essential quantities are constrained where appropriate.
