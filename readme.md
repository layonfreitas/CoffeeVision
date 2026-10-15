# ☕ CoffeeVision

> Monitoramento da lavoura de café para o pequeno produtor: **foto da folha + satélite + clima + mapa**, tudo num só app.

![Projete 2026](https://img.shields.io/badge/Projete-2026-8B5E3C)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?logo=flask&logoColor=white)
![Google Earth Engine](https://img.shields.io/badge/Google%20Earth%20Engine-Sentinel--2-4285F4?logo=google-earth&logoColor=white)
![YOLO](https://img.shields.io/badge/YOLO-ONNX-00FFFF)

<!-- 📸 Coloque aqui um GIF/print do app: ![CoffeeVision](docs/demo.gif) -->

## 🏆 Sobre o projeto

O CoffeeVision foi desenvolvido para o **Projete 2026** e [**<-- escreva aqui a premiação / colocação**].

Pequenos produtores raramente têm acesso à agricultura de precisão, e problemas como estresse hídrico, doenças e clima adverso costumam ser percebidos tarde demais. O CoffeeVision junta dados que normalmente ficam espalhados e os traduz em **alertas em português claro** e ações práticas. A decisão final continua sendo do produtor.

## ✨ Funcionalidades

- 🔬 **Diagnóstico de doenças pela foto da folha**: modelo YOLO exportado para ONNX que identifica *Cercospora*, *Bicho-mineiro*, *Phoma* e *Ferrugem*.
- 🛰️ **Índices de vegetação por satélite** (Sentinel-2 via Google Earth Engine): NDVI, NDRE, NDWI e CLMI, com mapas gerados para cada lavoura.
- 🚨 **Detecção de anomalias**: cada imagem é comparada com a série histórica da própria lavoura por **z-score**, e as áreas fora do normal viram alertas por índice e nível.
- 🐛 **Alerta de bicho-mineiro**: um classificador (Weka) combina CLMI, temperatura e precipitação.
- 🌡️ **Graus-dia acumulados (GDA)** calculados com temperaturas do Open-Meteo.
- 🌦️ **Clima em tempo real** (OpenWeatherMap) para a localização da lavoura.
- 🗺️ **Cadastro da lavoura no mapa** (desenho do contorno), com controle de safras.
- 🧩 **Zonas de manejo**: divisão da lavoura em áreas homogêneas a partir das séries de índices.
- 📄 **Laudos e observações** com exportação em PDF e envio por e-mail.
- 📬 **Avisos e alertas por e-mail** para produtores.

## 👥 Perfis de usuário

| Perfil | O que faz |
|---|---|
| **Produtor** | Cadastra a lavoura, acompanha clima e índices, fotografa folhas e vê o histórico de alertas |
| **Agrônomo** | Vincula-se a produtores, acompanha as lavouras e registra laudos e observações técnicas |
| **Cooperativa** | Gerencia usuários, acompanha o dashboard geral, envia avisos e exporta relatórios |

## 🏗️ Arquitetura

```
                        ┌──────────────────────────┐
                        │  Frontend (React + Vite) │
                        └────────────┬─────────────┘
         ┌───────────────┬───────────┴──────┬────────────────┐
         ▼               ▼                  ▼                ▼
 ┌───────────────┐ ┌─────────────┐ ┌────────────────┐ ┌───────────────┐
 │ banco_de_dados│ │     IA      │ │ backend_clima  │ │backend_indices│
 │ Flask + MySQL │ │ FastAPI     │ │ Node + Express │ │ FastAPI +     │
 │ auth, lavouras│ │ YOLO/ONNX,  │ │ OpenWeatherMap │ │ Earth Engine  │
 │ alertas, avisos│ │ Weka, GDA   │ │                │ │ (Sentinel-2)  │
 └───────────────┘ └─────────────┘ └────────────────┘ └───────────────┘
```

Um processamento diário (06:00, horário de Brasília) percorre todas as lavouras, calcula os índices, compara com o histórico e grava os alertas. Os pedidos entram numa **fila**, com um limite de processamentos simultâneos para respeitar a memória e a cota do Earth Engine.

## 🧰 Tecnologias

| Camada | Stack |
|---|---|
| Frontend | React 19, Vite, React Router, Leaflet / React-Leaflet, jsPDF + html2canvas |
| API principal | Python, Flask, MySQL, bcrypt, Gunicorn |
| IA | FastAPI, YOLO (ONNX Runtime), Weka (python-weka-wrapper3) |
| Sensoriamento remoto | Google Earth Engine, Sentinel-2 SR, xarray/zarr, rasterio, scikit-fuzzy |
| Clima | Node.js, Express, OpenWeatherMap, Open-Meteo |
| Armazenamento | MySQL (Aiven), Cloudinary (imagens), S3 compatível/R2 (séries temporais) |
| Infra | Docker, Caddy, GitHub Actions, Cloudflare Workers, Render |

## 📁 Estrutura

```
Projete_2K26/
├── frontend_projete/   # app React (login, mapa, histórico, laudos, painéis por perfil)
├── banco_de_dados/     # API Flask + schema.sql (usuários, lavouras, alertas, avisos...)
├── IA/API/             # FastAPI: classificação de folhas, CLMI, GDA
├── backend_indices/    # processamento de índices, z-score, anomalias e zonas de manejo
├── backend_clima/      # proxy de clima (Express)
├── site_projeto/       # página de apresentação e guia para o produtor
└── .github/workflows/  # disparo diário do processamento
```

## 🚀 Como rodar localmente

**Pré-requisitos:** Node 20+, Python 3.11+, MySQL, Java (para o Weka) e uma conta do Google Earth Engine.

```bash
# 1. Banco: crie o banco e rode banco_de_dados/database/schema.sql

# 2. API principal (porta 5000)
cd banco_de_dados
pip install -r requirements.txt
python app.py

# 3. IA (porta 8000)
cd IA/API
pip install -r requirements.txt -r ../../backend_indices/requirements.txt
uvicorn app:app --port 8000

# 4. Índices (porta 8001), use apenas 1 worker
cd backend_indices
pip install -r requirements.txt
uvicorn backend_server:app --port 8001

# 5. Clima (porta 5001)
cd backend_clima
npm install && node server.js

# 6. Frontend (porta 5173)
cd frontend_projete
npm install && npm run dev
```

> Cada serviço lê suas credenciais de um arquivo `.env` (banco, Earth Engine, Cloudinary, OpenWeatherMap, SMTP, etc.). **Nunca** faça commit desses arquivos.

## 🧠 Destaques técnicos

- **Fila de processamento** com travas por lavoura: a mesma lavoura nunca é processada por duas threads ao mesmo tempo.
- **Z-score por lavoura**: a anomalia é relativa ao histórico daquela área, e não a um limite fixo.
- **Mapas georreferenciados** em Web Mercator, com reamostragem bilinear dos pixels de 10 m.
- **Mensagens de erro em português claro**, pensadas para quem não é técnico.

## 🗺️ Próximos passos

- [ ] Ampliar o conjunto de doenças reconhecidas
- [ ] App mobile / PWA com uso offline
- [ ] Testes automatizados

## 👨‍💻 Equipe

- Cauã Eduardo Silva  
- Layon Rubens Motta de Freitas 
- Thiago Pereira da Costa 
-  Marcos José de Souza Filho
