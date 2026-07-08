<<<<<<< HEAD
FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY server.js .
EXPOSE 8080
CMD ["node", "server.js"]
=======
# Gunakan image Node.js versi 18
FROM node:18

# Tentukan folder kerja di dalam kontainer
WORKDIR /app

# Copy package.json dan install dependency
COPY package*.json ./
RUN npm install

# Copy semua file kode aplikasi
COPY . .

# Buka port 3000
EXPOSE 3000

# Perintah untuk menjalankan aplikasi
CMD ["node", "index.js"]

>>>>>>> 4256f0b (Commit pertama aplikasi logistik)
