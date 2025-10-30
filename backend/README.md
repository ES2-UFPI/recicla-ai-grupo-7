<h1 align="center">RECICLA AÍ BACKEND</h1>

<p align="center">
  <img src="https://img.shields.io/badge/FastAPI-0.119.1-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI">
  <img src="https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
</p>

Repositório do backend do projeto **Recicla Aí**, uma plataforma dedicada a promover a reciclagem e a sustentabilidade ambiental através da conexão entre produtores de resíduos, coletores e cooperativas de reciclagem.

## 📋 Sobre o Projeto

O **Recicla Aí** é uma API RESTful desenvolvida com FastAPI que facilita a gestão de materiais recicláveis e coletas. O sistema permite:

- 🔐 Autenticação e autorização de usuários (JWT)
- 👥 Gerenciamento de diferentes tipos de usuários (Produtor, Coletor, Cooperativa, Admin)
- ♻️ Cadastro e listagem de materiais recicláveis
- 📦 Solicitação e acompanhamento de coletas

## 🛠️ Tecnologias Utilizadas

- **FastAPI** - Framework web moderno e de alta performance
- **SQLAlchemy** - ORM para interação com banco de dados
- **SQLite** - Banco de dados para desenvolvimento local
- **PostgreSQL** - Banco de dados para produção
- **Pydantic** - Validação de dados e serialização
- **JWT** - Autenticação baseada em tokens
- **Passlib** - Hashing seguro de senhas
- **Docker** - Containerização da aplicação

# 🐳 Executando com Docker (Recomendado)

## Pré-requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e em execução
- [Git](https://git-scm.com/) instalado

## Desenvolvimento Local (com SQLite)

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/ES2-UFPI/recicla-ai-grupo-7-backend.git
   cd recicla-ai-grupo-7-backend
   ```

2. **Configure as variáveis de ambiente**:
   ```bash
   # Windows
   Copy-Item .env.example .env
   
   # Linux/Mac
   cp .env.example .env
   ```
   O ambiente local usa SQLite por padrão, não é necessário configurar banco de dados externo.

3. **Inicie o container**:
   ```bash
   docker compose -f docker-compose-local.yml up --build
   ```

4. **Acesse a aplicação**:
   - Backend: http://localhost:8000
   - Documentação Swagger: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

5. **Parar o container**:
   ```bash
   docker compose -f docker-compose-local.yml down
   ```

6. **Limpar banco de dados** (remove arquivo SQLite):
   ```bash
   rm recicla_ai.db
   ```

## Produção (com PostgreSQL)

Para executar o backend em produção conectando a um banco PostgreSQL externo:

1. **Configure o arquivo `.env`** com a URL do banco de produção:
   ```env
   DATABASE_URL=postgresql://usuario:senha@host-producao:5432/recicla_ai
   ```

2. **Execute**:
   ```bash
   docker compose -f docker-compose.yml up --build
   ```

3. **Acesse a aplicação**:
   - Backend: http://localhost:8000

# 📊 Gerenciamento do Banco de Dados

## Desenvolvimento Local (SQLite)

O ambiente de desenvolvimento usa SQLite, que cria um arquivo `recicla_ai.db` na raiz do projeto.

### Visualizar dados com ferramentas gráficas

Você pode usar ferramentas como **DB Browser for SQLite** ou **DBeaver** para visualizar o banco:
- **Arquivo**: `recicla_ai.db` (na raiz do projeto)

### Resetar banco de dados local

```bash
# Remover arquivo do banco
rm recicla_ai.db

# Reiniciar a aplicação para recriar o banco
docker compose -f docker-compose-local.yml restart
```

## Produção (PostgreSQL)

Em produção, o sistema se conecta a um banco PostgreSQL externo.

### Conectar ao PostgreSQL de produção

Use ferramentas como **DBeaver** ou **pgAdmin** com as credenciais configuradas no `.env`:
- **Host**: Conforme configurado em `DATABASE_URL`
- **Database**: `recicla_ai`
- **Credenciais**: Conforme ambiente de produção

# 🔧 SQLC - Geração de Código

O projeto utiliza [sqlc](https://sqlc.dev/) para gerar código Python type-safe a partir de queries SQL.

## Gerando código SQLC localmente

1. **Instale o sqlc**:
   - Linux/Mac: https://docs.sqlc.dev/en/latest/overview/install.html
   - Windows: Baixe o binário do [GitHub Releases](https://github.com/sqlc-dev/sqlc/releases)

2. **Gere os arquivos**:
   ```bash
   sqlc generate
   ```

Os arquivos gerados estarão em `sql/generated/`.

**Nota**: No Docker, os arquivos são gerados automaticamente durante o build.

# 💻 Executando Localmente (sem Docker)

## Preparando a Virtual Environment

Para garantir que todas as dependências do projeto sejam gerenciadas corretamente, é recomendado o uso de uma virtual environment. Siga os passos abaixo para configurar a sua:

1. **Criar a Virtual Environment**:
   ```bash
   python -m venv venv
   ```
   - Em algumas versões do linux é necessário atualizar a versão do venv, como no caso do python 3.12 no ubuntu 24.04:
   ```bash
   sudo apt install python3.12-venv -y
   ```

2. **Ativar a Virtual Environment**:
    - No Windows:
        ```bash
        venv\Scripts\activate
        ```
    - No macOS/Linux:
        ```bash
        source venv/bin/activate
        ```

3. **Instalar as Dependências**:
    ```bash
    pip install -r requirements.txt
    ```

4. **Configure o banco de dados** no arquivo `.env`:
   ```env
   # Para desenvolvimento local (SQLite)
   DATABASE_URL=sqlite:///./recicla_ai.db
   
   # Para produção (PostgreSQL)
   # DATABASE_URL=postgresql://usuario:senha@host:5432/recicla_ai
   ```

5. **Execute o projeto**:
   ```bash
   python main.py
   ```
   
   A aplicação estará disponível em: http://localhost:8000

# 📦 Requirements

As dependências do projeto estão listadas no arquivo `requirements.txt`. Certifique-se de instalar todas as dependências usando o comando mencionado acima.

## Como construir o arquivo requirements.txt

Para gerar o arquivo `requirements.txt` com as dependências atuais do seu ambiente virtual, utilize o seguinte comando:
```bash
pip freeze > requirements.txt
```

## Como instalar as dependências do requirements.txt

Para instalar todas as dependências listadas no arquivo `requirements.txt`, utilize o comando:
```bash
pip install -r requirements.txt
```

# 🗂️ Estrutura do Projeto

```
recicla-ai-grupo-7-backend/
├── src/
│   ├── api/                    # Configuração do servidor FastAPI
│   │   └── server.py
│   ├── database/               # Configuração de banco de dados
│   │   ├── connection.py       # Configuração de conexão e sessão
│   │   └── repository/         # Camada de acesso aos dados
│   │       ├── user_repo.py
│   │       └── residue_repo.py
│   ├── middlewares/            # Middlewares customizados
│   ├── models/                 # Modelos SQLAlchemy (ORM)
│   │   └── models.py           # Definição de tabelas
│   ├── routes/                 # Rotas da API (Controllers)
│   │   ├── auth_router.py      # Autenticação e usuários
│   │   ├── residue_router.py   # Materiais e coletas
│   │   └── utility_router.py   # Utilitários e validações
│   ├── schemas/                # Schemas Pydantic (Validação)
│   │   ├── user_schema.py
│   │   ├── residue_schema.py
│   │   └── return_schema.py
│   └── utils/                  # Utilitários
│       ├── hash_providers.py   # Hashing de senhas
│       └── token_providers.py  # Geração e validação JWT
├── sql/
│   ├── schema.sql              # Schema do banco de dados
│   ├── queries.sql             # Queries SQL
│   └── residue_queries.sql     # Queries específicas de resíduos
├── scripts/                    # Scripts auxiliares
│   └── linux-create-venv.sh
├── dbg/                        # Ferramentas de debug
├── main.py                     # Ponto de entrada da aplicação
├── requirements.txt            # Dependências Python
├── Dockerfile                  # Configuração Docker
├── docker-compose-local.yml    # Docker Compose para desenvolvimento
├── docker-compose.yml          # Docker Compose para produção
└── README.md                   # Este arquivo
```

# 📡 API Endpoints

## Autenticação (`/auth`)

### POST `/auth/signup`
Registra um novo usuário no sistema.

**Request Body:**
```json
{
  "name": "Jane Doe",
  "email": "jane.doe@example.com",
  "password": "StrongPass123!",
  "role": "PRODUTOR"
}
```

**Roles disponíveis:** `PRODUTOR`, `COLETOR`, `COOPERATIVA`, `ADMIN`

**Validações de senha:**
- Mínimo 8 caracteres
- Pelo menos 1 número
- Pelo menos 1 letra maiúscula
- Pelo menos 1 caractere especial (!@#$%&*)

### POST `/auth/login`
Realiza login e retorna tokens JWT.

**Request Body:**
```json
{
  "email": "jane.doe@example.com",
  "password": "StrongPass123!"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "token_type": "Bearer",
    "expires_in_minutes": 60
  }
}
```

### POST `/auth/refresh-token`
Renova o access token usando o refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJ..."
}
```

### GET `/auth/me`
Retorna informações do usuário autenticado.

**Headers:** `Authorization: Bearer <access_token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "role": "PRODUTOR",
    "is_active": true,
    "created_at": "2025-10-22T10:30:00"
  }
}
```

### POST `/auth/logout`
Realiza logout do usuário autenticado.

**Headers:** `Authorization: Bearer <access_token>`

## Resíduos (`/residue`)

### POST `/residue/register_material` 🔒 Admin
Registra um novo material reciclável no sistema.

**Headers:** `Authorization: Bearer <access_token>` (Requer role ADMIN)

**Request Body:**
```json
{
  "type": "plastic",
  "description": "Garrafa PET"
}
```

### GET `/residue/list_materials` 🔒
Lista todos os materiais recicláveis cadastrados.

**Headers:** `Authorization: Bearer <access_token>`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "type": "plastic",
      "description": "Garrafa PET"
    }
  ]
}
```

### POST `/residue/register_pickup` 🔒
Registra uma nova solicitação de coleta.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "address_id": "uuid-do-endereco",
  "scheduled_time": "2025-10-25T14:00:00",
  "items": [
    {
      "material_id": "uuid-do-material",
      "quantity": 10,
      "weight_kg": 5.5
    }
  ]
}
```

### GET `/residue/my_pickups` 🔒
Lista todas as coletas solicitadas pelo usuário logado.

**Headers:** `Authorization: Bearer <access_token>`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "producer_id": "uuid",
      "address_id": "uuid",
      "scheduled_time": "2025-10-25T14:00:00",
      "items": [
        {
          "material_id": "uuid",
          "quantity": 10,
          "weight_kg": 5.5
        }
      ]
    }
  ]
}
```

## 🔐 Autenticação

A API utiliza **JWT (JSON Web Tokens)** para autenticação. Após o login, você receberá:

- **access_token**: Token de curta duração (60 minutos) para acessar endpoints protegidos
- **refresh_token**: Token de longa duração para renovar o access_token

Para acessar endpoints protegidos, inclua o header:
```
Authorization: Bearer <access_token>
```

## 📊 Modelos de Dados

### User (Usuário)
```python
{
  "id": "uuid",
  "name": "string",
  "email": "string",
  "role": "PRODUTOR|COLETOR|COOPERATIVA|ADMIN",
  "is_active": "boolean",
  "created_at": "datetime"
}
```

### RecyclableMaterial (Material Reciclável)
```python
{
  "id": "uuid",
  "type": "string",
  "description": "string"
}
```

### PickupRequest (Solicitação de Coleta)
```python
{
  "id": "uuid",
  "producer_id": "uuid",
  "address_id": "uuid",
  "scheduled_time": "datetime",
  "items": [
    {
      "material_id": "uuid",
      "quantity": "integer",
      "weight_kg": "float"
    }
  ]
}
```

## 🧪 Testando a API

### Swagger UI (Documentação Interativa)

Após iniciar a aplicação, acesse:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

A documentação interativa permite testar todos os endpoints diretamente pelo navegador.

### Exemplo com cURL

```bash
# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane.doe@example.com",
    "password": "StrongPass123!"
  }'

# Listar materiais (com token)
curl -X GET http://localhost:8000/residue/list_materials \
  -H "Authorization: Bearer <seu_access_token>"
```

# 🚀 Deploy em Produção

Para deploy em servidores Linux (sem Docker Desktop):

1. **Instale Docker Engine**:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

2. **Adicione usuário ao grupo docker** (para evitar usar sudo):
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **Clone e configure o projeto**:
   ```bash
   git clone https://github.com/ES2-UFPI/recicla-ai-grupo-7-backend.git
   cd recicla-ai-grupo-7-backend
   nano .env  # Configure DATABASE_URL
   ```

4. **Execute**:
   ```bash
   docker compose -f docker-compose.yml up -d
   ```

5. **Ver logs**:
   ```bash
   docker compose -f docker-compose.yml logs -f
   ```

# 🔧 Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```env
# Database
# Desenvolvimento (SQLite)
DATABASE_URL=sqlite:///./recicla_ai.db

# Produção (PostgreSQL)
# DATABASE_URL=postgresql://usuario:senha@host:5432/recicla_ai

# JWT Secrets
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=7

# Server
HOST=0.0.0.0
PORT=8000
```

# 🐛 Solução de Problemas

## Erro de permissão do Docker

Se você receber um erro como `permission denied while trying to connect to the Docker daemon socket`:

```bash
# Adicione seu usuário ao grupo docker
sudo usermod -aG docker $USER

# Aplique as mudanças (escolha uma opção)
newgrp docker  # Temporário para sessão atual
# OU faça logout/login
# OU reinicie o sistema
```

## Container não inicia

```bash
# Verifique os logs
docker compose -f docker-compose-local.yml logs

# Verifique se a porta está em uso
sudo netstat -tulpn | grep :8000
```

## Porta 8000 já está em uso

Se a porta 8000 já estiver em uso, você pode:

1. Parar o processo que está usando a porta:
   ```bash
   # Encontrar o processo
   sudo lsof -i :8000
   
   # Ou
   sudo netstat -tulpn | grep :8000
   
   # Matar o processo (substitua PID pelo ID do processo)
   kill -9 PID
   ```

2. Ou alterar a porta no arquivo `.env`:
   ```env
   PORT=8001
   ```

## Banco de dados não conecta (Produção)

1. Verifique a `DATABASE_URL` no arquivo `.env`

2. Teste a conexão com o PostgreSQL:
   ```bash
   psql "postgresql://usuario:senha@host:5432/recicla_ai"
   ```

3. Verifique se o firewall permite conexões na porta 5432

## Erro com SQLite (Desenvolvimento)

1. Verifique se o arquivo `recicla_ai.db` tem permissões corretas:
   ```bash
   ls -la recicla_ai.db
   chmod 666 recicla_ai.db  # Se necessário
   ```

2. Remova e recrie o banco:
   ```bash
   rm recicla_ai.db
   python main.py
   ```

# 📝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Padrões de Código

- Use type hints em Python
- Siga a PEP 8 para estilo de código
- Documente funções e classes importantes
- Valide dados usando Pydantic schemas
- Trate exceções adequadamente

# 📄 Licença

Este projeto está sob a licença MIT.

# 👥 Equipe

Desenvolvido pelo **Grupo 7** - Engenharia de Software II - UFPI

# 📞 Contato

Para dúvidas ou sugestões, abra uma issue no repositório.

---

<p align="center">Feito com ❤️ e ♻️ para um mundo mais sustentável</p>