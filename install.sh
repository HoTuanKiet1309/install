#!/bin/bash
echo "Đang cài đặt SnackHub..."
mkdir -p snackhub && cd snackhub

# Tạo docker-compose.yml
cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  backend:
    image: meekit1307/snackshop-backend
    container_name: snackshop-backend
    ports:
      - "5000:5000"
    networks:
      - snackshop-network
    depends_on:
      - redis
      - mongodb
    restart: unless-stopped

  frontend:
    image: meekit1307/snackshop-frontend
    container_name: snackshop-frontend
    ports:
      - "3000:80"
    environment:
      - BACKEND_URL=http://backend:5000
    networks:
      - snackshop-network
    depends_on:
      - backend
    restart: unless-stopped

  admin:
    image: meekit1307/snackshop-admin
    container_name: snackshop-admin
    ports:
      - "3001:80"
    environment:
      - BACKEND_URL=http://backend:5000
    networks:
      - snackshop-network
    depends_on:
      - backend
    restart: unless-stopped

  redis:
    image: redis:alpine
    container_name: snackshop-redis
    networks:
      - snackshop-network
    command: redis-server --appendonly yes --requirepass snackshop
    restart: unless-stopped

  mongodb:
    image: mongo:5.0-focal
    container_name: snackshop-mongodb
    volumes:
      - mongodb_data:/data/db
      - ./mongodb-data/json:/json
      - ./mongodb-data/import.sh:/docker-entrypoint-initdb.d/import.sh
    environment:
      - MONGO_INITDB_DATABASE=snack-shop
    networks:
      - snackshop-network
    restart: unless-stopped

volumes:
  mongodb_data:

networks:
  snackshop-network:
    driver: bridge
EOL

# Tạo thư mục và tải dữ liệu mẫu
mkdir -p mongodb-data/json
curl -s -o install-data.sh https://raw.githubusercontent.com/meekit1307/snackhub/main/install-data.sh || {
  # Nếu không có file install-data.sh trên GitHub, tạo một script mặc định
  cat > mongodb-data/import.sh << 'EOL'
#!/bin/sh
mongoimport --db snack-shop --collection categories --file /json/snack-shop.categories.json --jsonArray --drop
mongoimport --db snack-shop --collection snacks --file /json/snack-shop.snacks.json --jsonArray --drop
mongoimport --db snack-shop --collection users --file /json/snack-shop.users.json --jsonArray --drop
mongoimport --db snack-shop --collection addresses --file /json/snack-shop.addresses.json --jsonArray --drop
mongoimport --db snack-shop --collection coupons --file /json/snack-shop.coupons.json --jsonArray --drop
EOL
  chmod +x mongodb-data/import.sh
}

# Khởi chạy ứng dụng
docker-compose up -d

echo "Cài đặt hoàn tất! Truy cập:"
echo "- Frontend: http://localhost:3000"
echo "- Admin: http://localhost:3001 (abc@gmail.com / password123)"